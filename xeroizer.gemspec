# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xeroizer/version'

Gem::Specification.new do |s|
  s.name = "xeroizer"
  s.version = Xeroizer::VERSION.dup
  s.date = "2016-03-01"
  s.authors = ["Wayne Robinson"]
  s.email = "wayne.robinson@gmail.com"
  s.summary = "Xero library"
  s.description = "Ruby library for the Xero accounting system API."
  s.homepage = "http://github.com/waynerobinson/xeroizer"
  s.licenses = ["MIT"]

  s.files = Dir["LICENSE.txt", "README.md", 'lib/**/*']
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency "rake"
  s.add_development_dependency "mocha"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "rest-client"
  s.add_development_dependency "turn"
  s.add_development_dependency "ansi"
  s.add_development_dependency "redcarpet"
  s.add_development_dependency "yard"
  s.add_dependency "builder", ">= 2.1.2"
  s.add_dependency "oauth", ">= 0.4.5"
  s.add_dependency "activesupport"
  s.add_dependency "nokogiri"
  s.add_dependency "tzinfo"
  s.add_dependency "i18n"
end
