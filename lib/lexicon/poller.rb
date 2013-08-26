require 'eventmachine'
require 'lexicon'

module Lexicon

  class Poller

    def initialize(opts={})
      @sources = opts[:sources] ||= []
      @timers  = setup_timers
    end

    def setup_timers
      timers = []

      @sources.each do |source|
        source.inputs.each do |input|
         timers.push lambda{
           EventMachine::PeriodicTimer.new(input.interval) do
            Log.debug "Poller - Time: #{Time.now} Polling: #{input.source} #{input.name}"
            input.poll
           end # EventMachine::PeriodicTimer.new
         }
        end # source.inputs.each
      end # sources.each

      timers
    end # def setup_timers

    def run
      EventMachine.run{
        @timers.each do |timer|
          timer.call
        end
      }
    end

  end # class Poller

end # module Lexicon
