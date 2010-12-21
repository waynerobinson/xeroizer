require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'
require 'yard'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the xero gateway.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  # t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
end