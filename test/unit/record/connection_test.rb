require 'unit_test_helper'

class ConnectionTest < Test::Unit::TestCase
  include TestHelper

  class FakeClient
    def initialize(get_result)
      @get_result = get_result
    end

    def get(path, _headers = {})
      if path == 'https://api.xero.com/connections'
        OpenStruct.new(plain_body: @get_result, code: 200)
      else
        raise 'unknown url'
      end
    end
  end

  it 'returns connections using the passed client' do
    client = FakeClient.new(get_file_as_string('connections.json'))
    result = Xeroizer::Connection.current_connections(client)
    assert_equal 2, result.count
    assert_equal "7f5fabdd-9565-416a-9b62-d53d852bb2a3", result.first.tenant_id
  end
end