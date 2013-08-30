require 'snmp'
require 'lexicon'
require 'lexicon/input'

module Lexicon

  # Base Input Object for Lexicon
  #
  class InputSNMP < Input

    COUNTER32_MAX = 4294967295
    COUNTER64_MAX = 18446744073709551615

    # :oid  => '1.2.3.4.5.6.7'
    # :type => :counter32, :counter64, :octetString
    #
    def initialize(opts={})
      @oid  = opts[:oid]  || raise(ArgumentError, 'SNMP OID Required')
      @type = opts[:type] || raise(ArgumentError, 'SNMP ObjectType Required')
      super(opts)
    end

    # Hash of time series:
    # { <timestamp> => <counter value> }
    #
    def decode_counter(series_hash={})
      # Compute differences, check for overflow
      result_hash  = {}

      # Sort hash keys by timestamp and give an index so we can compare with next
      timestamps = series_hash.keys.sort_by(&:to_i)
      timestamps.each_with_index do |time, index|
        next if index-1 < 0 # First entry

        current_time = time.to_i
        prev_time    = timestamps[index-1].to_i

        # Ensure timestamp is within two times the poll interval (heartbeat)
        next unless (@interval * 2) >= (current_time - prev_time)

        if series_hash[current_time].to_i < series_hash[prev_time].to_i # counter wrapped
          max_value = COUNTER32_MAX if @type == :counter32
          max_value = COUNTER64_MAX if @type == :counter64

          value = (max_value - series_hash[prev_time].to_i) + series_hash[current_time].to_i
        else
          value = series_hash[current_time].to_i - series_hash[prev_time].to_i
        end

        result_hash[current_time] = value
      end

      result_hash
    end

    # Poll the object for its data
    #
    def poll
      data = nil

      response = Source.find_by_name(@source).snmp.get(@oid)
      response.each_varbind do |vb|
         case
          when vb.value.is_a?(SNMP::OctetString)
            data = vb.value.to_s
          when vb.value.is_a?(SNMP::Counter64)
            data = vb.value.to_i
          when vb.value.is_a?(SNMP::Gauge32)
            data = vb.value.to_i
          when vb.value == SNMP::NoSuchInstance
            raise RuntimeError, "OID #{@oid} does not respond on device: #{@source}"
          else
            raise RuntimeError, "Unsupported SNMP data type: #{vb.value.class}"
        end
      end # response.each_varbind

      save({:time => Time.now.to_i, :data => data})
    end

    # Retrieve data between the begin and end time
    #
    def retrieve(begin_time, end_time)
      timestamps = []

      # Grab all the data within the timestamp range
      Base.redis.hkeys(@redis_key).each do |timestamp|
        timestamp = timestamp.to_i # ensure conversion to integer

        if timestamp >= begin_time.to_i && timestamp <= end_time.to_i
          timestamps.push timestamp
        end
      end # Base.redis.hkeys.each

      unless timestamps.empty? # do nothing if there were not any timestamps
        result = Base.redis.hmget(@redis_key, timestamps)
        series_hash = Hash[*timestamps.zip(result.map(&:to_i)).flatten]

        return decode_counter(series_hash) if @type == :counter32 or @type == :counter64
        return series_hash
      end

      {}
    end

    # Retrieve last (latest data) set
    #
    def retrieve_last

      case
        when (@type == :counter32 or @type == :counter64)
          # Must retrieve the last two timestamps by time for counter comparison
          timestamps = Base.redis.hkeys(@redis_key).sort_by(&:to_i).last(2).map(&:to_i)
          result = Base.redis.hmget(@redis_key, timestamps)
          set_hash = Hash[*timestamps.zip(result).flatten]
          set_hash = decode_counter(set_hash)
        else
          timestamp = Base.redis.hkeys(@redis_key).sort_by(&:to_i).last.to_i
          result = Base.redis.hmget(@redis_key, timestamp)
          set_hash = { timestamp => result[0].to_i } if result
      end

      set_hash
    end

    private

    def save(hash)
      Log.debug "InputSNMP - Saving Data Set: #{@redis_key}"
      Base.redis.hset(@redis_key, hash[:time], hash[:data])
      return hash
    end

  end # class Input

end # module Lexicon
