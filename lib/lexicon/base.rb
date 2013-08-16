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

    def self.init(opts_hash = {})
      @@directory = opts_hash[:directory]  || raise(ArgumentError, 'Directory required')
      log4r_opts  = opts_hash[:log4r_opts] ||= 'Lexicon'

      # Define Lexicon::Log constant as self or reconfigure Log
      Lexicon.send(:remove_const, :Log) if Lexicon.const_defined?(:Log)
      Lexicon.const_set(:Log, Logger.new(log4r_opts))

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

  end # module Base

end # module Lexicon
