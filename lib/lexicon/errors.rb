module Lexicon

  # Raised when a required argument is not supplied
  #
  class ArgumentError < ArgumentError; end

  # Raised when a source exists with the same name
  #
  class DuplicateName < ArgumentError; end

  # Raised by Base when an invalid directory is specified
  #
  class InvalidDirectory < RuntimeError; end

  # Raised when Base is not initialized properly
  #
  class NotInitialized < RuntimeError; end

end # module Lexicon
