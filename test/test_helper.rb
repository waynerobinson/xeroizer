require "rubygems"
require 'test/unit'
require 'mocha'
require 'shoulda'
require 'pp'
require 'pry'

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

  $VERBOSE=nil

  STUB_XERO_CALLS   = ENV["STUB_XERO_CALLS"].nil? ? true : (ENV["STUB_XERO_CALLS"] == "true") unless defined? STUB_XERO_CALLS

  CONSUMER_KEY      = ENV["CONSUMER_KEY"]     || "fake_key"     unless defined?(CONSUMER_KEY)
  CONSUMER_SECRET   = ENV["CONSUMER_SECRET"]  || "fake_secret"  unless defined?(CONSUMER_SECRET)
  PRIVATE_KEY_PATH  = ENV["PRIVATE_KEY_PATH"] || "fake_key"     unless defined?(PRIVATE_KEY_PATH)

  CLIENT_ID     = ENV["CLIENT_ID"]     || "fake_client_id"     unless defined?(CLIENT_ID)
  CLIENT_SECRET = ENV["CLIENT_SECRET"] || "fake_client_secret" unless defined?(CLIENT_SECRET)

  # Helper constant for checking regex
  GUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/ unless defined?(GUID_REGEX)

  def get_file_as_string(filename)
    if File.exist?(File.dirname(__FILE__) + "/stub_responses/" + filename)
      File.read(File.dirname(__FILE__) + "/stub_responses/" + filename)
    else
      puts "WARNING: File does not exist: #{filename}"
      nil
    end
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
    client_for_stubbing.stubs(:http_get).with {|client, url, params| url =~ /#{model_name}$/ }.returns(get_record_xml("#{model_name_for_file(model_name).underscore.pluralize}".to_sym))

    @client.send("#{model_name.singularize}".to_sym).all.each do | record |
      next if record.id.nil?

      client_for_stubbing.stubs(:http_get).with {|client, url, params| url =~ /#{model_name}\/#{record.id}$/ }.returns(get_record_xml("#{model_name_for_file(model_name).underscore.singularize}".to_sym, record.id))
    end
  end

  # some models have a parent-child relationship, where you should call:
  # Child.find(parent.id) to find items of type child belonging to the parent
  # eg. http://developer.xero.com/documentation/payroll-api/leaveapplications/
  def mock_child_relationship_api(child, parent)
    mock_api(child)
    mock_api(parent)
    # grab the ID of each parent record
    # if we call api/child/parent_id, return the appropriate child xml
    @client.send("#{parent.singularize}".to_sym).all.each do | record |
      next if record.id.nil?
      client_for_stubbing.stubs(:http_get).with {|client, url, params|
        url =~ /#{child}\/#{record.id}$/
        }.returns(get_record_xml("#{model_name_for_file(child).underscore.singularize}".to_sym, record.id))
    end
  end

  def mock_report_api(report_type)
    client_for_stubbing.stubs(:http_get).with { | client, url, params | url =~ /Reports\/#{report_type}$/ }.returns(get_report_xml(report_type))
  end

  def client_for_stubbing
    payroll_application? ? @client.application : @client
  end

  def model_name_for_file(model_name)
    payroll_application? ? "payroll_#{model_name}" : model_name
  end

  def payroll_application?
    @client.is_a? Xeroizer::PayrollApplication
  end
end

Shoulda::Context::ClassMethods.class_eval do
  %w{it must can}.each do |m|
    alias_method m, :should
  end

  alias_method :must_eventually, :should_eventually
end
