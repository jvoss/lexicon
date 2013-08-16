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

      it 'should load a configuration from a YAML file' do
        lexicon = Lexicon::Base.load_yaml('spec/mocks/base.config.yaml')
        lexicon.directory.should == '/tmp/lexicon'
        Lexicon::Log.level.should == Log4r::INFO
      end

      it 'should initialize a new Lexicon::Base object' do
        lexicon_class = Lexicon::Base

        lexicon = Lexicon::Base.init(:directory => @tmpdir)
        lexicon.init?.should be true
        Lexicon.const_defined?(:Log).should be true
        Lexicon::Log.is_a?(Lexicon::Logger).should be true
      end

      it 'should raise if the directory argument is missing' do
        expect{Base.init({})}.to raise_error Lexicon::ArgumentError
      end

    end # describe 'Base'

  end # class RSpec

end # end module Lexicon
