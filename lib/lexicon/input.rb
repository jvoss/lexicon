require 'lexicon'
require 'lexicon/errors'

module Lexicon

  # Base Input Object for Lexicon
  #
  class Input

    attr_reader :description, :name

    def initialize(opts={})
      @name        = opts[:name] || raise(ArgumentError, 'Name required')
      @description = opts[:description]

      save # save a copy of self to Redis
    end

    # Delete self from Redis
    #
    def delete
      result = Base.redis.hdel(:inputs, name)
      if result == 1
        Log.info "Deleting Input object from Redis: #{name}"
      else
        raise UnknownInput, "Cannot delete non-existent Input object in Redis: #{name}"
      end
      result
    end

    def description=(string)
      @description = string.to_s
      save
    end

    # Return an array of all input objects
    #
    def self.find_all
      inputs = []
      Base.redis.hgetall(:inputs).each_value do |input|
        inputs.push Marshal.load(input)
      end
      inputs
    end

    # Find an input object by name (string)
    #
    def self.find_by_name(name)
      marshal = Base.redis.hget(:inputs, name)
      if marshal
        input_obj = Marshal.load(marshal)
        return input_obj
      end
    end

    # Poll the object for its data
    #
    def poll
      {:time => Time.now.to_i, :data => nil}
    end

    # Save input object to Redis
    # **Will overwrite any existing source with same name**
    #
    def save
      result = Base.redis.hset(:inputs, self.name, Marshal.dump(self))
      Log.debug "Saving Input object to Redis: #{self.name}"
      result
    end

  end # class Input

end # module Lexicon
