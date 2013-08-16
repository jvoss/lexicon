require 'fileutils'
require 'rspec'
require 'tmpdir'
require 'lexicon'
require 'lexicon/base'

module Lexicon

  class RSpec

    describe 'Base' do

      before :all do
        @tmpdir = Dir.mktmpdir
      end

      after :all do
        FileUtils.rm_r(@tmpdir)
      end

      it 'should raise if not initialized' do
        expect{Base.directory}.to raise_error Lexicon::NotInitialized
      end

      it 'should return the status of whether it is initialized or not' do
        Lexicon::Base.init?.should be false
        Lexicon::Base.init(:directory => @tmpdir)
        Lexicon::Base.init?.should be true
      end

      it 'should load a configuration from a YAML file' do
        lexicon = Lexicon::Base.load_yaml('spec/mocks/base.config.yaml')
        lexicon.directory.should == '/tmp/lexicon'
        Lexicon::Log.level.should == Log4r::INFO
      end

      it 'should initialize a new Lexicon::Base object' do
        lexicon = Lexicon::Base.init(:directory => @tmpdir)
        lexicon.init?.should be true
        Lexicon.const_defined?(:Log).should be true
        Lexicon::Log.is_a?(Lexicon::Logger).should be true
      end

      it 'should raise if the directory argument is missing' do
        expect{Base.init({})}.to raise_error Lexicon::ArgumentError
      end

      it 'should return the base directory' do
        Lexicon::Base.directory.should == @tmpdir
      end

    end # describe 'Base'

  end # class RSpec

end # end module Lexicon
