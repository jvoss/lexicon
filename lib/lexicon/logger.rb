require 'log4r'
require 'lexicon'

module Lexicon

  # Lexicon's Log object is a wrapper for Log4r::Logger
  #
  class Logger < Log4r::Logger

    def initialize(log4r_opts = 'Lexicon')
      super(log4r_opts)
      self.outputters = Log4r::Outputter.stdout if self.outputters.empty?
    end # def initialize

    # Pass methods to Log4r
    #
    def method_missing(m, *args, &block)
      super(m, *args, &block)
    end # def method_missing

    # Respond_to? method asks
    #
    def respond_to?(m, include_private = false)
      super(m, include_private)
    end

  end # class Logger

end # module Lexicon
