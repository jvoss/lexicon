require 'redis'
require 'yaml'
require 'lexicon'
require 'lexicon/errors'
require 'lexicon/logger'

# Hiera <- yaml defaults

module Lexicon

  # The base object for the Lexicon application
  #
  module Base

    @@directory = nil
    @@init      = false
    @@redis     = nil
    @@sources   = []

    def self.init(opts_hash = {})
      @@directory = opts_hash[:directory]  || raise(ArgumentError, 'Directory required')
      log_opts    = opts_hash[:log_opts]   ||= {}

      # Establish Redis if options given
      @@redis = Redis.new(opts_hash[:redis_opts]) if opts_hash[:redis_opts]

      # Define Lexicon::Log constant as self or reconfigure Log
      Lexicon.send(:remove_const, :Log) if Lexicon.const_defined?(:Log)
      Lexicon.const_set(:Log, Logger.new(log_opts))

      @@init = true
      return self
    end # def initialize

    # Has Base been initialized?
    #
    def self.init?
      @@init
    end

    def self.init_check
      raise NotInitialized, 'Lexicon has not been configured' unless init?
    end

    def self.directory
      init_check
      @@directory
    end

    # Load a source object by name that has been saved to a Redis store
    #
    def self.load_redis_source(name)
      init_check
      marshal = @@redis.hget(:sources, name)
      if marshal
        source_obj = Marshal.load(marshal)
        return source_obj
      end
    end

    # Load the sources from Redis into an array
    #
    def self.load_redis_sources
      init_check
      sources = []
      @@redis.hgetall(:sources).each_value do |source|
        source_obj = Marshal.load(source)
        sources.push source_obj
      end
      sources
    end

    # Load a Lexicon configuration file
    #
    def self.load_yaml(filename)
      self.init YAML.load_file(filename)
    end

    # Handle saving sources to appropriate store
    #
    def self.save_source(source_obj)
      init_check
      raise ArgumentError, 'Must be Lexicon::Source' unless source_obj.is_a?(Source)
      if source_by_name(source_obj.name)
        raise DuplicateName, 'A Lexicon::Source with this name already exists'
      end
      @@redis ? save_redis_source(source_obj) : @@sources.push(source_obj)
      source_obj
    end

    # Save a source object to Redis
    #
    def self.save_redis_source(source_obj)
      init_check
      @@redis.hset(:sources, source_obj.name, Marshal.dump(source_obj))
      Log.debug "Base - Source object Redis set: #{source_obj.name}"
    end

    # Sources array
    #
    def self.sources
      @@redis ? load_redis_sources : @@sources
    end

    # Return a source by name
    #
    def self.source_by_name(name)
      @@redis ? (return load_redis_source(name)) \
              : sources.each{|source| return source if source.name == name}
      nil
    end

    # Collect all of the instantiated sources (observer for Source class)
    #
    def self.update(source_obj)
      save_source(source_obj)
      Log.debug "Base - Source object updated: #{source_obj.name}"
    end

  end # module Base

end # module Lexicon
