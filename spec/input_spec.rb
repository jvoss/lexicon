require 'lexicon'
require 'lexicon/input'
require 'rspec_helpers'

module Lexicon

  class RSpec

    describe 'Input' do

      before :all do
        Lexicon::Base.init(@@base_options)
        @test_name = "--test#{rand(100)}"
      end

      after :each do
        # Clean up from each test if needed
        Input.find_by_name(@test_name).delete if Input.find_by_name(@test_name)
      end

      it 'should require a name during initialization' do
        expect{Input.new()}.to raise_error Lexicon::ArgumentError
      end

      it 'should not require a description during initialization' do
        Input.new(:name => @test_name).description.should be nil
      end

      it 'should provide a method to return all defined inputs' do
        Lexicon::Input.new(:name => @test_name)
        inputs = Lexicon::Input.find_all
        inputs.class.should be Array
        inputs.size.should_not be 0
      end

      it 'should provide a method for inputs to be found by name' do
        Lexicon::Input.new(:name => @test_name)
        Lexicon::Input.find_by_name(@test_name).is_a?(Input).should be true
      end

      it 'should be able to save themselves to Redis' do
        obj = Lexicon::Input.new(:name => @test_name)
        obj.save
      end

      it 'should save themselves to Redis when their description changes' do
        description = 'new description'
        obj = Lexicon::Input.new(:name => @test_name)
        obj.description.should be nil
        obj.description = description
        Input.find_by_name(@test_name).description.should == 'new description'
      end

      it 'should be able to delete themselves from Redis' do
        obj = Lexicon::Input.new(:name => @test_name)
        Input.find_by_name(@test_name).should_not be nil
        obj.delete
        Input.find_by_name(@test_name).should be nil
      end

      it 'should raise if trying to delete and is non-existent in Redis' do
        obj = Lexicon::Input.new(:name => @test_name)
        obj.delete
        expect{obj.delete}.to raise_error UnknownInput
      end

      it 'should provide a stub for polling data from itself' do
        obj = Lexicon::Input.new(:name => @test_name)
        obj.poll.class.should be Hash
        obj.poll.keys.include?(:time).should be true
        obj.poll.keys.include?(:data).should be true
      end

    end # describe 'Sources'

  end # class RSpec

end # end module Lexicon
