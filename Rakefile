require 'rake'
require 'minitest/test_task'
require 'rdoc/task'
require 'rubygems'
require 'yard'
require 'bundler/gem_tasks'

desc 'Default: run all tests.'
task :default => :test

desc 'Run all tests (unit + integration).'
# Separate processes: the unit suite's WebMock teardown would clash with VCR in-process.
task :test => ['test:unit', 'test:integration']

namespace :test do
  desc 'Run unit tests'
  Minitest::TestTask.create(:unit) do |t|
    t.test_globs = ['test/unit/**/*_test.rb']
  end

  desc 'Run integration tests (replay recorded cassettes; see test/integration/README.md)'
  Minitest::TestTask.create(:integration) do |t|
    t.test_globs = ['test/integration/**/*_test.rb']
  end
end

YARD::Rake::YardocTask.new do |t|
  # t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
end
