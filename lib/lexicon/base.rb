require 'lexicon'
require 'lexicon/errors'
require 'lexicon/logger'

module Lexicon

  # The base object for the Lexicon application
  #
  class Base

    def initialize(opts_hash = {})
      @directory   = opts_hash[:directory]  || raise(ArgumentError, 'Directory required')
      @log4r_opts  = opts_hash[:log4r_opts] ||= 'Lexicon'

      # Initialize logger as Lexicon::LOG constant
      Lexicon.const_set(:LOG, Lexicon::Logger.new(@log4r_opts))
    end # def initialize

  end # class Base

end # module Lexicon
