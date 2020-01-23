require 'unit_test_helper'

class GenericApplicationTest < Test::Unit::TestCase
  include TestHelper

  setup do
    @headers = {"User-Agent" => "Xeroizer/2.15.5"}
    @unitdp = 4
    @options = {
      default_headers: @headers,
      unitdp: @unitdp
    }
  end

  it "fails when provided an invalid client" do
    client = "an invalid client"

    assert_raises Xeroizer::InvalidClientError do
      Xeroizer::GenericApplication.new(client, {})
    end
  end

  context "oauth" do
    setup do
      client = Xeroizer::OAuth.new(CONSUMER_KEY, CONSUMER_SECRET, @options)
      @application = Xeroizer::GenericApplication.new(client, @options)
    end

    should "pass default headers" do
      assert_equal(@headers, @application.default_headers)
    end

    should "pass unitdp value" do
      assert_equal(@unitdp, @application.unitdp)
    end
  end

  context "oauth 2" do
    setup do
      client = Xeroizer::OAuth2.new(CLIENT_ID, CLIENT_SECRET, @options)
      @application = Xeroizer::GenericApplication.new(client, @options)
    end

    should "pass default headers" do
      assert_equal(@headers, @application.default_headers)
    end

    should "pass unitdp value" do
      assert_equal(@unitdp, @application.unitdp)
    end
  end
end
