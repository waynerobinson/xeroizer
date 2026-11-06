require 'rake'
require 'minitest/test_task'
require 'rdoc/task'
require 'rubygems'
require 'yard'
require 'bundler/gem_tasks'

desc 'Default: run unit tests.'
task :default => :test

Minitest::TestTask.create(:test) do |t|
  t.test_globs = ['test/unit/**/*_test.rb']
end

namespace :test do
  Minitest::TestTask.create(:integration) do |t|
    t.test_globs = ['test/integration/**/*_test.rb']
  end

  Minitest::TestTask.create(:unit) do |t|
    t.test_globs = ['test/unit/**/*_test.rb']
  end
end

# Minitest::TestTask sets its own desc, so ours are applied after create.
{
  'test' => 'Run unit tests',
  'test:unit' => 'Run unit tests',
  'test:integration' => 'Run integration tests against a Xero Demo Company (see test/integration/README.md)',
}.each { |name, text| Rake::Task[name].clear_comments.add_description(text) }

namespace :xero do
  desc 'Refresh the integration tests\' Xero tokens, logging in through the browser if needed'
  task :token do
    require_relative 'test/support/xero_token'
    XeroToken.run
  end

  desc 'Log in to Xero through the browser and save tokens for the integration tests'
  task :login do
    require_relative 'test/support/xero_token'
    XeroToken.run(login: true)
  end
end

YARD::Rake::YardocTask.new do |t|
  # t.files   = ['lib/**/*.rb', OTHER_PATHS]   # optional
  # t.options = ['--any', '--extra', '--opts'] # optional
end
