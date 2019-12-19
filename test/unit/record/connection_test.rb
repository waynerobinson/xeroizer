require 'unit_test_helper'

class ConnectionTest < UnitTestCase
  include TestHelper

  setup do
    @client = Xeroizer::OAuth2Application.new("client id", "client secret", access_token: "access token")
  end

  it 'returns connections using the passed client' do
    client = FakeClient.new(get_file_as_string('connections.json'))
    result = Xeroizer::Connection.current_connections(client)
    assert_equal 2, result.count
    assert_equal "7f5fabdd-9565-416a-9b62-d53d852bb2a3", result.first.tenant_id
  end
end
