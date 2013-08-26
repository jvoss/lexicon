require 'lexicon'
require 'lexicon/input'
require 'rspec_helpers'

module Lexicon

  class RSpec

    describe 'Input' do

      before :all do
        Lexicon::Base.init(@@base_options)
        @test_name = "--test#{rand(100)}"
        @test_host = Lexicon::Source.new(:name => "--test#{rand(100)}")
      end

      after :each do
        # Clean up from each test if needed
        @test_host.inputs.each {|input| @test_host.delete_input(input)}
      end

      after :all do
        @test_host.delete
      end

      it 'should require a name during initialization' do
        expect{Input.new()}.to raise_error Lexicon::ArgumentError
      end

      it 'should not require a description during initialization' do
        Input.new(:name => @test_name, :interval => 5, :source => @test_host).description.should be nil
      end

      it 'should provide a stub for polling data from itself' do
        obj = Lexicon::Input.new(:name => @test_name, :interval => 5, :source => @test_host)
        obj.poll.class.should be Hash
        obj.poll.keys.include?(:time).should be true
        obj.poll.keys.include?(:data).should be true
      end

      it 'should provide a stub for retrieving data from itself' do
        obj = Lexicon::Input.new(:name => @test_name, :interval => 5, :source => @test_host)
        obj.respond_to?(:retrieve).should be true
        obj.retrieve(0, 1).should be nil
      end

    end # describe 'Inputs'

  end # class RSpec

end # end module Lexicon
