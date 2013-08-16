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
    @@sources   = []

    def self.init(opts_hash = {})
      @@directory = opts_hash[:directory]  || raise(ArgumentError, 'Directory required')
      log_opts    = opts_hash[:log_opts]   ||= {}

      # Define Lexicon::Log constant as self or reconfigure Log
      Lexicon.send(:remove_const, :Log) if Lexicon.const_defined?(:Log)
      Lexicon.const_set(:Log, Logger.new(log_opts))

      @@init = true
      return self
    end # def initialize

    def self.init?
      @@init
    end

    def self.directory
      raise NotInitialized, 'Lexicon has not been configured' if @@directory.nil?
      @@directory
    end

    # Load a Lexicon configuration file
    #
    def self.load_yaml(filename)
      self.init YAML.load_file(filename)
    end

    # Sources array
    #
    def self.sources
      @@sources
    end

  end # module Base

end # module Lexicon
