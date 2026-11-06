require 'unit_test_helper'
require 'open3'

# The Demo Company check runs when integration_test_case.rb is required, so each case loads it in a child process.
class IntegrationTestCaseTest < UnitTestCase
  TEST_DIR = File.expand_path("..", __dir__)

  def test_aborts_on_an_org_that_is_not_a_demo_company
    _, err, status = require_integration_test_case(demo: false)

    refute status.success?
    assert_includes err, "is not a Demo Company."
  end

  def test_loads_on_a_demo_company
    _, err, status = require_integration_test_case(demo: true)

    assert status.success?, err
  end

  private

  def require_integration_test_case(demo:)
    script = <<~RUBY
      require "webmock"
      include WebMock::API
      WebMock.enable!
      WebMock.disable_net_connect!
      xml = File.read("#{TEST_DIR}/stub_responses/organisations.xml")
      xml = xml.sub("<IsDemoCompany>true", "<IsDemoCompany>#{demo}")
      stub_request(:get, %r{api\\.xro/2\\.0/Organisation}).to_return(body: xml)
      require "integration_test_case"
    RUBY
    env = ENV.keys.grep(/\AXERO_/).to_h { |key| [key, nil] }.merge(
      "XERO_CLIENT_ID" => "dummy_id",
      "XERO_CLIENT_SECRET" => "dummy_secret",
      "XERO_ACCESS_TOKEN" => "dummy_access_token",
      "XERO_TENANT_ID" => "dummy_tenant"
    )
    Open3.capture3(
      env,
      RbConfig.ruby,
      "-I", TEST_DIR,
      "-I", File.expand_path("../lib", TEST_DIR),
      "-e", script
    )
  end
end
