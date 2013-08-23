require 'lexicon'
require 'lexicon/source'
require 'rspec_helpers'

module Lexicon

  class RSpec

    describe 'Sources' do

      before :all do
        Lexicon::Base.init(@@base_options)
        @test_hostname = "--test#{rand(100)}"
      end

      after :each do
        # Clean up from each test if needed
        Source.find_by_name(@test_hostname).delete if Source.find_by_name(@test_hostname)
      end

      it 'should require a name during initialization' do
        expect{Source.new()}.to raise_error Lexicon::ArgumentError
      end

      it 'should now allow a source to be named "sources"' do
        expect{Source.new(:name => 'sources')}.to raise_error Lexicon::ArgumentError
      end

      it 'should not require a description during initialization' do
        Source.new(:name => @test_hostname).description.should be nil
      end

      it 'should provide a method to associate Input objects with sources' do
        source = Lexicon::Source.new(:name => @test_hostname)
        Lexicon::Input.new(:name => 'test', :interval => 5, :source => source)
        # Instantiated input object automatically calls #add_input
        source.inputs.size.should be 1
      end

      it 'should provide a method to list all associated Input objects' do
        source = Lexicon::Source.new(:name => @test_hostname)
        source.inputs.class.should be Array
        source.inputs.size.should equal 0
        Lexicon::Input.new(:name => 'test', :interval => 5, :source => source)
        source.inputs.class.should be Array
        source.inputs.size.should equal 1
      end

      it 'should provide a method to delete source objects' do
        source = Lexicon::Source.new(:name => @test_hostname)
        input  = Lexicon::Input.new(:name => 'test', :interval => 5, :source => source)
        source.inputs[0].name.should == input.name
        source.delete_input(input)
        source.inputs.size.should be 0
      end

      it 'should provide a method to return all defined sources' do
        Lexicon::Source.new(:name => @test_hostname)
        sources = Lexicon::Source.find_all
        sources.class.should be Array
        sources.size.should_not be 0
      end

      it 'should provide a method for sources to be found by name' do
        Lexicon::Source.new(:name => @test_hostname)
        Lexicon::Source.find_by_name(@test_hostname).is_a?(Source).should be true
      end

      it 'should be able to save themselves to Redis' do
        obj = Lexicon::Source.new(:name => @test_hostname)
        obj.save
      end

      it 'should save themselves to Redis when their description changes' do
        description = 'new description'
        obj = Lexicon::Source.new(:name => @test_hostname)
        obj.description.should be nil
        obj.description = description
        Source.find_by_name(@test_hostname).description.should == 'new description'
      end

      it 'should be able to delete themselves from Redis' do
        obj = Lexicon::Source.new(:name => @test_hostname)
        Source.find_by_name(@test_hostname).should_not be nil
        obj.delete
        Source.find_by_name(@test_hostname).should be nil
      end

      it 'should raise if trying to delete and is non-existent in Redis' do
        obj = Lexicon::Source.new(:name => @test_hostname)
        obj.delete
        expect{obj.delete}.to raise_error UnknownSource
      end

      it 'should be able to support SNMP' do
        obj = Lexicon::Source.new(:name      => @test_hostname,
                                  :snmp_opts => {:host => '127.0.0.1'}
                                 )
        obj.snmp.class.should be SNMP::Manager
      end

    end # describe 'Sources'

  end # class RSpec

end # end module Lexicon
