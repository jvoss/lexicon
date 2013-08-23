require 'lexicon'
require 'lexicon/errors'

module Lexicon

  # Base Input Object for Lexicon
  #
  class Input

    attr_reader :description, :interval, :name

    def initialize(opts={})
      @description = opts[:description]
      @interval    = opts[:interval] || raise(ArgumentError, 'Interval required')
      @name        = opts[:name]     || raise(ArgumentError, 'Name required')

      @source      = validate_source opts[:source]

      # Register self with source object
      Source.find_by_name(@source).add_input(self)
    end

    def description=(string)
      @description = string.to_s
    end

    # Poll the object for its data
    #
    def poll
      {:time => Time.now.to_i, :data => nil}
    end

    def validate_source(source_obj)
      raise ArgumentError, 'Source required' unless source_obj.is_a?(Source)
      source_obj.name
    end

  end # class Input

end # module Lexicon
