require 'rspec'
require 'lexicon/version'

module Lexicon

  class RSpec

    # Good practice - ensuring version constant exists for gemspec, etc
    #
    describe 'Version' do

      it 'should be a defined constant' do
        Lexicon.const_defined?(:VERSION).should be true
      end

    end # describe 'Version'

  end # class RSpec

end # end module Lexicon