require "rubygems"

require 'test/unit'
require 'mocha'
require 'shoulda'
require 'pp'

require File.dirname(__FILE__) + '/../lib/xeroizer.rb'

$: << File.join(File.dirname(__FILE__), "acceptance") 

module TestHelper

  # The integration tests can be run against the Xero test environment.  You must have a company set up in the test
  # environment, and you must have set up a customer key for that account.
  #
  # You can then run the tests against the test environment using the commands (linux or mac):
  # export STUB_XERO_CALLS=false  
  # rake test
  # (this probably won't work under OAuth?)
  #
  
  STUB_XERO_CALLS   = ENV["STUB_XERO_CALLS"].nil? ? true : (ENV["STUB_XERO_CALLS"] == "true") unless defined? STUB_XERO_CALLS
  
  CONSUMER_KEY      = ENV["CONSUMER_KEY"]     || "fake_key"     unless defined?(CONSUMER_KEY)
  CONSUMER_SECRET   = ENV["CONSUMER_SECRET"]  || "fake_secret"  unless defined?(CONSUMER_SECRET)
  PRIVATE_KEY_PATH  = ENV["PRIVATE_KEY_PATH"] || "fake_key"     unless defined?(PRIVATE_KEY_PATH)
  
  # Helper constant for checking regex
  GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

  def get_file_as_string(filename)
    File.read(File.dirname(__FILE__) + "/stub_responses/" + filename)
  end
  
  def get_record_xml(type, id = nil)
    if id.nil?
      get_file_as_string("#{type}.xml")
    else
      get_file_as_string("records/#{type}-#{id}.xml")
    end
  end
  
  def get_report_xml(report_type)
    get_file_as_string("reports/#{report_type.underscore}.xml")
  end
  
  def mock_api(model_name)
    @client.stubs(:http_get).with {|client, url, params| url =~ /#{model_name}$/ }.returns(get_record_xml("#{model_name.underscore.pluralize}".to_sym))
    @client.send("#{model_name.singularize}".to_sym).all.each do | record |
      @client.stubs(:http_get).with {|client, url, params| url =~ /#{model_name}\/#{record.id}$/ }.returns(get_record_xml("#{model_name.underscore.singularize}".to_sym, record.id))
    end
  end
  
  def mock_report_api(report_type)
    @client.stubs(:http_get).with { | client, url, params | url =~ /Reports\/#{report_type}$/ }.returns(get_report_xml(report_type))
  end
    
end

Shoulda::Context::ClassMethods.class_eval do
  %w{it must can}.each do |m|
    alias_method m, :should
  end
  
  alias_method :must_eventually, :should_eventually
end
