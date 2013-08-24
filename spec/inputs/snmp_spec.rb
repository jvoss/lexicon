require 'yaml'
require 'lexicon'
require 'lexicon/input'
require 'lexicon/inputs/snmp'
require 'rspec_helpers'

module Lexicon

  class RSpec

    describe 'InputSNMP' do

      COUNTER_DECODE_HASH = {
          1377303010 => 1000,
          1377303260 => 1000,
          1377303270 => 1000,
          1377303280 => 1000,
          1377303290 => 1000,
          1377304310 => 2000,
          1377304320 => 1000,
          1377304330 => 1000,
          1377305010 => 1000,
          1377305030 => 1000,
      }

      before :all do
        Lexicon::Base.init(@@base_options)
        @test_name = "--test#{rand(100)}"
        @test_host = Lexicon::Source.new( :name      => "--test#{rand(100)}",
                                          :snmp_opts => { :host    => '127.0.0.1',
                                                          :timeout => 1}
                                        )

        @test_input_options = { :name     => @test_name,
                                :interval => 10,
                                :source   => @test_host
                              }
      end

      after :each do
        # Clean up from each test if needed
        @test_host.inputs.each {|input| @test_host.delete_input(input)}
      end

      after :all do
        @test_host.delete
      end

      it 'should require an SNMP OID during initialization' do
        expect{
          InputSNMP.new(@test_input_options.dup.merge(:type => :counter64))
        }.to raise_error(Lexicon::ArgumentError, 'SNMP OID Required')
      end

      it 'should require an SNMP ObjectType during initialization' do
        expect{
          InputSNMP.new(@test_input_options.dup.merge(:oid => '1.2.3.4'))
        }.to raise_error(Lexicon::ArgumentError, 'SNMP ObjectType Required')
      end

      it 'should decode counter32 time series hashes' do
        input = InputSNMP.new(@test_input_options.dup.merge(:oid => '1.2.3.4', :type => :counter32))
        counter32_hash = YAML.load_file('spec/mocks/snmp_counter32_hash.yaml')
        input.decode_counter(counter32_hash).should == COUNTER_DECODE_HASH
      end

      it 'should decode counter64 time series hashes' do
        input = InputSNMP.new(@test_input_options.dup.merge(:oid => '1.2.3.4', :type => :counter64))
        counter64_hash = YAML.load_file('spec/mocks/snmp_counter64_hash.yaml')
        input.decode_counter(counter64_hash).should == COUNTER_DECODE_HASH
      end

      it 'should poll Source object\'s SNMP Manager' do
        input = InputSNMP.new(@test_input_options.dup.merge(:oid => '1.2.3.4', :type => :integer))
        expect{input.poll}.to raise_error(SNMP::RequestTimeout)
      end

      it 'should retrieve data from Redis between two given timestamps' do
        input = InputSNMP.new(@test_input_options.dup.merge(:oid => '1.2.3.4', :type => :integer))
        [ 1000, 2000, 3000, 4000, 5000 ].each do |timestamp|
          Base.redis.hset(input.instance_variable_get(:@redis_key), timestamp, rand(3))
        end

        result = input.retrieve(2000, 4000)
        result.class.should be Hash
        result.size.should be 3
        result.keys.should == [2000, 3000, 4000]
      end

    end # describe 'InputSNMP'

  end # class RSpec

end # end module Lexicon
