# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xeroizer/version'

Gem::Specification.new do |s|
  s.name = "xeroizer"
  s.version = Xeroizer::VERSION.dup
  s.authors = ["Wayne Robinson"]
  s.email = ["wayne.robinson@gmail.com", "api@xero.com"]
  s.summary = "Ruby Library for Xero accounting API"
  s.description = "Ruby library for the Xero accounting API.  Originally developed by Wayne Robinson, now maintained by the Xero API Team & Xero/Ruby developer community."
  s.homepage = "http://github.com/waynerobinson/xeroizer"
  s.licenses = ["MIT"]
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/waynerobinson/xeroizer/issues",
    "changelog_uri" => "https://github.com/waynerobinson/xeroizer/releases",
    "source_code_uri" => "https://github.com/waynerobinson/xeroizer",
    "documentation_uri" => "https://developer.xero.com/documentation/",
    "mailing_list_uri" => "https://developer.xero.com/subscribe-to-the-xero-api-developer-mailing-list"
  }

  s.files = Dir["LICENSE.txt", "README.md", 'lib/**/*']
  s.test_files = `git ls-files -- test/*`.split("\n")
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 3.1"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "mocha"
  s.add_development_dependency "shoulda-context", "~> 2.0"
  s.add_development_dependency "minitest"
  s.add_development_dependency "redcarpet"
  s.add_development_dependency "yard"
  s.add_development_dependency "webmock"
  s.add_development_dependency "vcr"
  s.add_development_dependency "rdoc"
  s.add_dependency "builder", ">= 2.1.2"
  s.add_dependency "oauth2", ">= 2.0", "< 3.0"
  s.add_dependency "activesupport", ">= 7.0"
  s.add_dependency "nokogiri"
  s.add_dependency "tzinfo"
  s.add_dependency "i18n"
end
