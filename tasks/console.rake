require 'rake'

desc 'Open an irb session preloaded with this library'
task :console do
  sh "irb -I lib -r lexicon.rb #{'-rubygems' if RUBY_VERSION < '1.9'}"
end
