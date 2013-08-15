require 'log4r'
require 'lexicon'

module Lexicon

  class Logger

    def initialize(log4r_opts = 'Lexicon')
      @log4r = Log4r::Logger.new(log4r_opts)
      @log4r.outputters = Log4r::Outputter.stdout
    end # def initialize

    # Pass methods to Log4r
    #
    def method_missing(m, *args, &block)
      @log4r.send(m, *args, &block)
    end # def method_missing

    # TODO respond_to?

  end # class Logger

end # module Lexicon
