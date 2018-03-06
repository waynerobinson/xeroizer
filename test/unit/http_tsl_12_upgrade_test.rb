require 'test_helper'
require 'json'

class HttpTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @application = Xeroizer::PrivateApplication.new(CONSUMER_KEY, CONSUMER_SECRET, PRIVATE_KEY_PATH, {:xero_url => 'https://api-tls.xero.com/', :site => 'https://api-tls.xero.com/'})
    @applicationExternal = Xeroizer::PrivateApplication.new(CONSUMER_KEY, CONSUMER_SECRET, PRIVATE_KEY_PATH, {:xero_url => 'https://www.howsmyssl.com', :site => 'https://www.howsmyssl.com'})
  end

  context "Connect to Xero TLS 1.2 Test endpoint" do
    should "receive a 301 response (endpoint redirects on success)" do
      begin
        @application.http_get(@application.client, "https://api-tls.xero.com/")
      rescue Xeroizer::Http::BadResponse => e
        assert_equal "Unknown response code: 301", e.message, "Unexpected Response Code (Xero): Check TLS 1.2 is set"
      end
      
    end
  end

  context "Connect to external TLS 1.2 Test endpoint" do
    should "respond with tls version 1.2" do
      response = @applicationExternal.http_get(@applicationExternal.client, "https://www.howsmyssl.com/a/check")
      jsonResponse = JSON.parse(response)
      assert_equal "TLS 1.2", jsonResponse['tls_version'], "Unexpected Response (External): Check TLS 1.2 is set"
    end
  end
end

