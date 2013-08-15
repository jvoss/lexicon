module Lexicon

  # Raised when a required argument is not supplied
  #
  class ArgumentError < ArgumentError; end

  # Raised by Base when an invalid directory is specified
  #
  class InvalidDirectory < RuntimeError; end

end # module Lexicon
