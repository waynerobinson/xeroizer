require "test_helper"
require "acceptance_test"

class ConnectionsTest < Test::Unit::TestCase
  include AcceptanceTest

  should "be able to hit Xero to get current connections via OAuth2" do
    connections = AcceptanceTestHelpers.oauth2_client.current_connections
    assert_not_nil connections.first.tenant_id
  end
end
