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

  # Raised when the input does not exist
  # (i.e. Object is attempted to be deleted from Redis but is not in store)
  class UnknownInput < RuntimeError; end

  # Raised when the source does not exist
  # (i.e. Object is attempted to be deleted from Redis but is not in store)
  #
  class UnknownSource < RuntimeError; end

end # module Lexicon
