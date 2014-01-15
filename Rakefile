require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'rubygems'
require 'yard'
require 'bundler/gem_tasks'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the xero gateway.'
Rake::TestTask.new(:test) do |t|
  t.libs << ['lib', 'test']
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

namespace :test do
  desc 'Run acceptance/integration tests'
  Rake::TestTask.new(:acceptance) do |t|
    t.libs << ['lib', 'test']
    t.pattern = 'test/acceptance/**/*_test.rb'
    t.verbose = true
  end

  desc 'Run unit tests'
  Rake::TestTask.new(:unit) do |t|
    t.libs << ['lib', 'test']
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
  end
end

YARD::Rake::YardocTask.new do |t|
  # t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
end
