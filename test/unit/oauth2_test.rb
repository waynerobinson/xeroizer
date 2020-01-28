require 'unit_test_helper'

class OAuth2Test < UnitTestCase
  include TestHelper

  setup do
    @client_id = 'client_id'
    @client_secret = 'client_secret'
    @access_token = 'access_token'
    @site = 'https://example.com'
    @content_type = 'application/xml'
    @path = '/path'
    @uri = "#{@site}#{@path}"
    @response_body = '{"test": true}'
    @status_code = 200
    @additional_headers = {foo: 'bar'}
    @request_body = "xml"
    @request_headers = { 'Content-Type' => @content_type }
    @tenant_id = "tenant"
  end

  def instance
    Xeroizer::OAuth2.new(@client_id, @client_secret, {
        site: @site
    }).tap do |oauth2|
      oauth2.authorize_from_access(@access_token)
    end
  end

  context "get" do
    setup do
      stub_request(:get, @uri).
          with(
              headers: {
                  'Authorization' => "Bearer #{@access_token}",
              }
          ).to_return(status: @status_code, body: @response_body, headers: {})
    end

    context "when tenant_id is not present" do
      should "make a get request" do
        result = instance.get(@path)
        assert_equal(result.code, @status_code)
        assert_equal(result.plain_body, @response_body)
        assert_requested :get, @uri
        assert_not_requested :get, @uri, headers: { "Xero-tenant-id" => @tenant_id }
      end
    end

    context "when tenant_id is present" do
      setup do
        @client = instance
        @client.tenant_id = @tenant_id
      end

      should "make a get request with the tenant_id" do
        result = @client.get(@path)
        assert_equal(result.code, @status_code)
        assert_equal(result.plain_body, @response_body)
        assert_requested :get, @uri, headers: { "Xero-tenant-id" => @tenant_id }
      end
    end
  end

  context "delete" do
    setup do
      stub_request(:delete, @uri).
          with(
              headers: {
                  'Authorization' => "Bearer #{@access_token}",
              }
          ).to_return(status: @status_code, body: @response_body, headers: {})
    end

    context "when tenant_id is not present" do
      should "make a delete request" do
        result = instance.delete(@path)
        assert_equal(result.code, @status_code)
        assert_not_requested :delete, @uri, headers: { "Xero-tenant-id" => @tenant_id }
      end
    end


    context "when tenant_id is present" do
      setup do
        @client = instance
        @client.tenant_id = @tenant_id
      end

      should "make a delete request with the tenant_id" do
        result = @client.delete(@path)
        assert_equal(result.code, @status_code)
        assert_equal(result.plain_body, @response_body)
        assert_requested :delete, @uri, headers: { "Xero-tenant-id" => @tenant_id }
      end
    end
  end

  context "post" do
    setup do
      stub_request(:post, @uri).
          with(
              body: @request_body,
              headers: {
                  'Authorization' => "Bearer #{@access_token}",
                  'Content-Type' => @content_type,
              }).
          to_return(status: @status_code, body: @response_body, headers: @request_headers)

    end

    context "when tenant_id is not present" do
      should "make a post request" do
        result = instance.post(@path, @request_body, @request_headers)
        assert_equal(result.code, @status_code)
        assert_equal(result.plain_body, @response_body)
        assert_not_requested :post, @uri, headers: { "Xero-tenant-id" => @tenant_id }
      end
    end

    context "when tenant_id is present" do
      setup do
        @client = instance
        @client.tenant_id = @tenant_id
      end

      should "make a post request with the tenant_id" do
        result = @client.post(@path, @request_body, @request_headers)
        assert_equal(result.code, @status_code)
        assert_equal(result.plain_body, @response_body)
        assert_requested :post, @uri, headers: { "Xero-tenant-id" => @tenant_id }
      end
    end
  end

  context "put" do
    setup do
      stub_request(:put, @uri).
          with(
              body: @request_body,
              headers: {
                  'Authorization' => "Bearer #{@access_token}",
                  'Content-Type' => @content_type,
              }).
          to_return(status: @status_code, body: @response_body, headers: @request_headers)
    end

    context "when tenant_id is not present" do
      should "make a put request" do
        result = instance.put(@path, @request_body, @request_headers)
        assert_equal(result.code, @status_code)
        assert_equal(result.plain_body, @response_body)
        assert_not_requested :put, @uri, headers: { "Xero-tenant-id" => @tenant_id }
      end
    end

    context "when tenant_id is present" do
      setup do
        @client = instance
        @client.tenant_id = @tenant_id
      end

      should "make a put request" do
        result = @client.put(@path, @request_body, @request_headers)
        assert_equal(result.code, @status_code)
        assert_equal(result.plain_body, @response_body)
        assert_requested :put, @uri, headers: { "Xero-tenant-id" => @tenant_id }
      end
    end
  end
end
