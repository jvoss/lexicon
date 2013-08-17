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

    # Sources array
    #
    def self.sources
      @@sources
    end

    # Return a source by name
    #
    def self.source_by_name(name)
      @@sources.each{|source| return source if source.name == name}
      nil
    end

    # Collect all of the instantiated sources
    #
    def self.update(source_obj)
      init_check
      raise ArgumentError, 'Update must be Lexicon::Source' unless source_obj.is_a?(Source)
      if self.source_by_name(source_obj.name)
        raise DuplicateName, 'Update must be uniquely named Lexicon::Source'
      end
      @@sources.push(source_obj) unless @@sources.include?(source_obj)
    end

  end # module Base

end # module Lexicon
