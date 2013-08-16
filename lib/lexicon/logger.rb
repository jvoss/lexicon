require 'log4r'
require 'lexicon'

module Lexicon

  # Lexicon's Log object is a wrapper for Log4r::Logger
  #
  class Logger

    def initialize(opts_hash={})
      name       = opts_hash[:name]       ||= 'Lexicon'
      level      = opts_hash[:level]      ||= :ERROR
      outputters = opts_hash[:outputters] ||= Log4r::Outputter.stdout

      @log = Log4r::Logger.new(name)
      self.level      = Log4r.const_get(level)
      self.outputters = outputters
      self.debug 'Logging started'
    end # def initialize

    # Pass methods to Log4r
    #
    def method_missing(m, *args, &block)
      @log.send(m, *args, &block)
    end # def method_missing

    # Respond_to? method asks
    #
    def respond_to?(m, include_private = false)
      @log.respond_to?(m, include_private)
    end

  end # class Logger

end # module Lexicon
