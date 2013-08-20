require 'lexicon'
require 'lexicon/source'
require 'rspec_helpers'

module Lexicon

  class RSpec

    describe 'Sources' do

      before :all do
        Lexicon::Base.init(@@base_options)
      end

      before :each do
        # Clean up from previous RSpec run if needed
        Base.delete_source(Base.source_by_name('test')) if Base.source_by_name('test')
      end

      it 'should require a name during initialization' do
        expect{Source.new()}.to raise_error Lexicon::ArgumentError
      end

      it 'should not require a description during initialization' do
        Source.new(:name => 'test').description.should be nil
      end

      it 'should register Lexicon::Base as an observer of a Source object' do
        #double_base = double(Lexicon::Base.init(:directory => '/tmp'))
        #double_base.should_receive(:update).once
        Source.new(:name => 'test')
        Lexicon::Base.source_by_name('test').is_a?(Source).should be true
      end

    end # describe 'Sources'

  end # class RSpec

end # end module Lexicon
