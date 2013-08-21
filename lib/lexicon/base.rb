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

    # Expose Redis class variable to other classes
    #
    def self.redis
      init_check
      @@redis
    end

  end # module Base

end # module Lexicon
