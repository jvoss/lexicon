require 'lexicon/logger'

module Lexicon

  class RSpec

    describe 'Logger' do

      before :all do
        @logger = Lexicon::Logger.new()
      end

      it 'should initialize a new Lexicon::Logger object' do
        @logger.is_a?(Lexicon::Logger).should be true
      end

      it 'should initialize a Logger object with default stdout outputter' do
        @logger.outputters[0].name.should == 'stdout'
      end

    end # describe 'Base'

  end # class RSpec

end # end module Lexicon
