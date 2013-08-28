# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lexicon/version'

Gem::Specification.new do |spec|
  spec.name          = "lexicon"
  spec.version       = Lexicon::VERSION
  spec.authors       = ["Jonathan P. Voss"]
  spec.email         = ["jvoss@onvox.net"]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>=1.9.2'

  # https://github.com/morellon/rrd-ffi
  spec.add_dependency 'eventmachine'
  #spec.add_dependency "rrd-ffi"
  spec.add_dependency 'log4r'
  spec.add_dependency 'redis'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'snmp'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rack-test"
end