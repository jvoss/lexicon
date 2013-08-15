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

      it 'should initialize a new Lexicon::Base object' do
        lexicon = Lexicon::Base.new(:directory => @tmpdir)
        lexicon.is_a?(Lexicon::Base).should be true
        Lexicon.const_defined?(:LOG).should be true
        Lexicon::LOG.is_a?(Lexicon::Logger).should be true
      end

      it 'should raise if the directory argument is missing' do
        expect{Base.new({})}.to raise_error Lexicon::ArgumentError
      end

      it 'should load a configuration from a YAML file' do
        lexicon = Lexicon::Base.load_yaml('spec/mocks/base.config.yaml')
        lexicon.directory.should == '/tmp/lexicon'
      end

    end # describe 'Base'

  end # class RSpec

end # end module Lexicon
