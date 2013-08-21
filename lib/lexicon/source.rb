require 'lexicon'
require 'lexicon/base'
require 'lexicon/errors'

module Lexicon

  class Source

    attr_reader :description, :name

    # Initialize a new source. Sources are objects containing objects that
    # poll and save information.
    #
    def initialize(hash={})
      @name        = hash[:name]        || raise(Lexicon::ArgumentError, 'Name required')
      @description = hash[:description]

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

    def description=(string)
      @description = string
      save
    end

    # Return an array of all source objects
    #
    def self.find_all
      sources = []
      Base.redis.hgetall(:sources).each_value do |source|
        source_obj = Marshal.load(source)
        sources.push source_obj
      end
      sources
    end

    def self.find_by_name(name)
      marshal = Base.redis.hget(:sources, name)
      if marshal
        source_obj = Marshal.load(marshal)
        return source_obj
      end
    end

    # Load a source from a configuration YAML.
    #
    def self.load_yaml(filename)
      self.new YAML.load_file(filename)
    end

    # Save source object to Redis
    # **Will overwrite any existing source with same name**
    #
    def save
      result = Base.redis.hset(:sources, self.name, Marshal.dump(self))
      Log.debug "Saving Source object to Redis: #{self.name}"
      result
    end

  end # class Source

end # module Lexicon
