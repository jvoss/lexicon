require 'lexicon/logger'

module Lexicon

  class RSpec

    describe 'Logger' do

      before :all do
        @logger = Lexicon::Logger.new()
      end

      it 'should initialize a new Lexicon::Logger object' do
        @logger.is_a?(Lexicon::Logger).should be true
        # Which is a wrapper for Log4r:
        @logger.is_a?(Log4r::Logger).should be true
      end

      it 'should initialize a Logger object with default stdout outputter' do
        @logger.outputters[0].name.should == 'stdout'
      end

      # Log Levels
      #
      it 'should support Log4r logging level DEBUG' do
        @logger.respond_to?(:debug, 'debug level').should be true
      end

      it 'should support Log4r logging level INFO' do
        @logger.respond_to?(:info, 'info level').should be true
      end

      it 'should support Log4r logging level WARN' do
        @logger.respond_to?(:warn, 'warn level').should be true
      end

      it 'should support Log4r logging level ERROR' do
        @logger.respond_to?(:error, 'error level').should be true
      end

      it 'should support Log4r logging level FATAL' do
        @logger.respond_to?(:fatal, 'fatal level').should be true
      end

    end # describe 'Logger'

  end # class RSpec

end # end module Lexicon
