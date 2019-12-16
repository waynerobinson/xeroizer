require 'unit_test_helper'

class OAuth2Test < Test::Unit::TestCase
  include TestHelper

  def setup
    @client_id = 'client_id'
    @client_secret = 'client_secret'
    @access_token = 'access_token'
    @site = 'https://example.com'
    @path = '/path'
    @response_body = '{"test": true}'
    @status_code = 200
    @additional_headers = {foo: 'bar'}
  end

  def instance
    Xeroizer::OAuth2.new(@client_id, @client_secret, {
        site: @site
    }).tap do |oauth2|
      oauth2.authorize_from_access(@access_token)
    end
  end

  should "make a get request" do
    stub_request(:get, "https://example.com/path").
        with(
            headers: {
                'Authorization' => "Bearer #{@access_token}",
            }
        ).to_return(status: @status_code, body: @response_body, headers: {})

    result = instance.get(@path)
    assert_equal(result.code, @status_code)
    assert_equal(result.plain_body, @response_body)
  end

  should "make a post request" do
    request_body = "xml"
    request_headers = {'Content-Type' => 'application/xml'}

    stub_request(:post, "https://example.com/path").
        with(
            body: request_body,
            headers: {
                'Authorization' => "Bearer #{@access_token}",
                'Content-Type' => 'application/xml',
            }).
        to_return(status: @status_code, body: @response_body, headers: request_headers)


    result = instance.post(@path, request_body, request_headers)
    assert_equal(result.code, @status_code)
    assert_equal(result.plain_body, @response_body)
  end
end
