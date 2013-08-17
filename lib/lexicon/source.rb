require 'observer'
require 'lexicon'
require 'lexicon/base'
require 'lexicon/errors'

module Lexicon

  class Source
    include Observable

    attr_accessor :description, :name

    # Initialize a new source. Sources are objects containing objects that
    # poll and save information.
    #
    def initialize(hash={})
      @name        = hash[:name]        || raise(Lexicon::ArgumentError, 'Name required')
      @description = hash[:description]

      _add_base_observer
    end # def initialize

    # Load a source from a configuration YAML.
    #
    def self.load_yaml(filename)
      self.new YAML.load_file(filename)
    end

    private

    def _add_base_observer
      self.add_observer(Base)
      changed
      notify_observers(self)
    end

  end # class Source

end # module Lexicon
