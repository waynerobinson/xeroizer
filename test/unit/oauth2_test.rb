require 'unit_test_helper'

class OAuth2Test < Test::Unit::TestCase
  include TestHelper

  def setup
    @client_id = 'client_id'
    @client_secret = 'client_secret'
    @access_token = 'access_token'
  end

  def instance
    Xeroizer::OAuth2.new(@client_id, @client_secret).tap do |oauth2|
      oauth2.authorize_from_access(@access_token)
    end
  end

  should "makes a get request" do
    path = 'http://example.com/path'
    body = '{"test": true}'
    status_code = 200

    stub_request(:get, path).
        with(
            headers: {
                'Authorization' => "Bearer #{@access_token}",
            }
        ).to_return(status: status_code, body: body, headers: {})

    result = instance.get(path)
    assert_equal(result.code, status_code)
    assert_equal(result.plain_body, body)
  end
end
