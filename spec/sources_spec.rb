require 'lexicon'
require 'lexicon/source'
require 'rspec_helpers'

module Lexicon

  class RSpec

    describe 'Sources' do

      before :all do
        Lexicon::Base.init(@@base_options)
      end

      it 'should require a name during initialization' do
        expect{Source.new()}.to raise_error Lexicon::ArgumentError
      end

      it 'should not require a description during initialization' do
        Source.new(:name => 'test3').description.should be nil
      end

      it 'should register Lexicon::Base as an observer of a Source object' do
        #double_base = double(Lexicon::Base.init(:directory => '/tmp'))
        #double_base.should_receive(:update).once
        Source.new(:name => 'test4')
        Lexicon::Base.source_by_name('test4').is_a?(Source).should be true
      end

    end # describe 'Sources'

  end # class RSpec

end # end module Lexicon
