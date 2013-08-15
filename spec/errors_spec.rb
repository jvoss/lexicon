require 'rspec'
require 'lexicon'
require 'lexicon/errors'

module Lexicon

  class RSpec

    # Good practice - ensuring certain error classes exist
    #
    describe 'Errors' do

      it 'should contain a class for handling ArgumentErrors' do
        Lexicon.const_defined?(:ArgumentError).should be true
      end

      it 'should contain a class for invalid directory errors' do
        Lexicon.const_defined?(:InvalidDirectory).should be true
      end

    end # describe 'Errors'

  end # class RSpec

end # end module Lexicon