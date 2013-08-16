require 'yaml'
require 'lexicon'
require 'lexicon/errors'
require 'lexicon/logger'

# Hiera <- yaml defaults

module Lexicon

  # The base object for the Lexicon application
  #
  class Base

    attr_reader :directory

    def initialize(opts_hash = {})
      @directory = opts_hash[:directory]  || raise(ArgumentError, 'Directory required')
      log4r_opts = opts_hash[:log4r_opts] ||= 'Lexicon'

      # Define Lexicon::Log constant as self
      _const_set(:Log, Logger.new(log4r_opts))
    end # def initialize

    # Load a Lexicon configuration file
    #
    def self.load_yaml(filename)
      self.new YAML.load_file(filename)
    end

    private

    def _const_set(sym, obj)
      # undefine the constants first
      Lexicon.send(:remove_const, sym) if Lexicon.const_defined?(sym)
      Lexicon.const_set(sym, obj)
    end # def const_set

  end # class Base

end # module Lexicon
