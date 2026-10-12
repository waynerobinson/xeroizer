# frozen_string_literal: true

require 'integration_test_case'

class ConnectionsTest < IntegrationTestCase
  should 'be able to hit Xero to get current connections via OAuth2' do
    connections = oauth2_client.current_connections
    refute_nil connections.first.tenant_id
  end
end
