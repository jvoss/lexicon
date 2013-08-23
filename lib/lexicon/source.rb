require 'snmp'
require 'lexicon'
require 'lexicon/base'
require 'lexicon/errors'

module Lexicon

  class Source

    attr_reader :description, :name, :snmp_opts

    # Initialize a new source. Sources are objects containing objects that
    # poll and save information.
    #
    def initialize(hash={})
      @name        = hash[:name]        || raise(Lexicon::ArgumentError, 'Name required')
      @description = hash[:description]
      @snmp_opts   = hash[:snmp_opts]

      save # Save a copy of self to Redis on creation
    end # def initialize

    # Delete self from Redis
    #
    def delete
      result = Base.redis.hdel(:sources, name)
      if result == 1
        Log.info "Deleting Source object from Redis: #{name}"
      else
        raise UnknownSource, "Cannot delete non-existent Source object in Redis: #{name}"
      end
      result
    end

    # Set the description
    #
    def description=(string)
      @description = string.to_s
      save
    end

    # Return an array of all source objects
    #
    def self.find_all
      sources = []
      Base.redis.hgetall(:sources).each_value do |source|
        sources.push Marshal.load(source)
      end
      sources
    end

    # Find a source object by name (string)
    #
    def self.find_by_name(name)
      marshal = Base.redis.hget(:sources, name)
      if marshal
        source_obj = Marshal.load(marshal)
        return source_obj
      end
    end

    # Save source object to Redis
    # **Will overwrite any existing source with same name**
    #
    def save
      result = Base.redis.hset(:sources, self.name, Marshal.dump(self))
      Log.debug "Saving Source object to Redis: #{self.name}"
      result
    end

    # Instantiate a new SNMP Manager
    #
    def snmp
      raise ArgumentError, 'No SNMP options found for source' if @snmp_opts.nil?
      SNMP::Manager.new(@snmp_opts)
    end

    # Change SNMP options
    #
    def snmp_opts=(hash={})
      @snmp_opts = hash
    end

  end # class Source

end # module Lexicon
