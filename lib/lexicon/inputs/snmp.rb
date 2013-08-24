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
          else
            raise RuntimeError, "Unsupported SNMP data type: #{vb.value.class}"
        end
      end # response.each_varbind

      save({:time => Time.now.to_i, :data => data})
    end

    # Retrieve data between the begin and end time
    #
    def retrieve(begin_time, end_time)
      series_hash = {}

      # Grab all the data within the timestamp range
      Base.redis.hkeys(@redis_key).each do |timestamp|
        timestamp = timestamp.to_i # ensure conversion to integer

        if timestamp >= begin_time.to_i && timestamp <= end_time.to_i
          series_hash[timestamp] = Base.redis.hget(@redis_key, timestamp)
        end
      end

      return decode_counter(series_hash) if @type == :counter32 or @type == :counter64
      series_hash
    end

    private

    def save(hash)
      Log.debug "InputSNMP - Saving Data Set: #{@redis_key}"
      Base.redis.hset(@redis_key, hash[:time], hash[:data])
      return hash
    end

  end # class Input

end # module Lexicon
