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
      redis_opts  = opts_hash[:redis_opts] || raise(ArgumentError, 'Redis options required')

      # Establish Redis if options given
      @@redis = Redis.new(redis_opts)

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

    # Load a Lexicon configuration file
    #
    def self.load_yaml(filename)
      self.init YAML.load_file(filename)
    end

    # Save source object to Redis
    #
    def self.save_source(source_obj)
      init_check
      raise ArgumentError, 'Must be Lexicon::Source' unless source_obj.is_a?(Source)
      @@redis.hset(:sources, source_obj.name, Marshal.dump(source_obj))
      Log.debug "Base - Source object Redis saved: #{source_obj.name}"
      source_obj
    end

    # Sources array loaded from Redis marshaled objects
    #
    def self.sources
      init_check
      sources = []
      @@redis.hgetall(:sources).each_value do |source|
        source_obj = Marshal.load(source)
        sources.push source_obj
      end
      sources
    end

    # Return a source by name
    #
    def self.source_by_name(name)
      init_check
      marshal = @@redis.hget(:sources, name)
      if marshal
        source_obj = Marshal.load(marshal)
        return source_obj
      end
    end

    # Collect all of the instantiated sources (observer for Source class)
    #
    def self.update(action, source_obj)
      init_check
      raise ArgumentError, 'Must be Lexicon::Source' unless source_obj.is_a?(Source)
      if source_by_name(source_obj.name) && action == :new
        raise DuplicateName, 'A Lexicon::Source with this name already exists'
      end
      save_source(source_obj)
      Log.debug "Base - Source object updated: #{source_obj.name}"
    end

  end # module Base

end # module Lexicon
