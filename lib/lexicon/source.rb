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
      @name        = validate_name(hash[:name])
      @description = hash[:description]
      @snmp_opts   = hash[:snmp_opts]

      save # Save a copy of self to Redis on creation
    end # def initialize

    # Add an input object to a source
    #
    def add_input(input_obj)
      raise ArgumentError, 'Must be Input object' unless input_obj.is_a?(Input)
      # check for existing input with same name
      inputs.each do |existing_input|
        if input_obj.name == existing_input.name
          raise DuplicateName, 'Input with this name already exists'
        end
      end

      Base.redis.hset(self.name, :inputs, Marshal.dump(inputs.push(input_obj)))
    end

    # Delete self from Redis
    #
    def delete
      result = Base.redis.hdel(:sources, name)
      if result == 1
        delete_all_inputs
        Log.info "Deleting Source object from Redis: #{name}"
      else
        raise UnknownSource, "Cannot delete non-existent Source object in Redis: #{name}"
      end
      result
    end

    # Delete an input object from a source
    #
    def delete_input(input_obj)
      new_inputs = inputs.delete_if do |input|
        input_obj.name == input.name
      end
      Base.redis.del(input_obj.instance_variable_get(:@redis_key))  # delete data
      Base.redis.hset(self.name, :inputs, Marshal.dump(new_inputs)) # dump current input names
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

    # Return a hash of arrays of intervals and associated inputs with this source
    # Inputs stored in Redis as hash:
    #   "source_name" "inputs" <Marshaled array>
    #
    def inputs
      Base.redis.hexists(self.name, :inputs) ?              \
          Marshal.load(Base.redis.hget(self.name, :inputs)) \
      : []
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

    private

    # Delete all inputs from a self
    #
    def delete_all_inputs
      result = Base.redis.hdel(self.name, :inputs)
      if result == 1
        Log.info "Deleted all Input objects from Source: #{name}"
      else
        Log.debug "Delete all called but no sources to delete from #{name}"
      end
    end

    def validate_name(string)
      raise(Lexicon::ArgumentError, 'Name required') unless string.is_a?(String)
      raise(Lexicon::ArgumentError, 'Illegal name') if string == 'sources'
      raise(Lexicon::DuplicateName, 'Source with this name already exists') if Source.find_by_name(string)
      string.to_s
    end

  end # class Source

end # module Lexicon
