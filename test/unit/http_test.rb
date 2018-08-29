require 'test_helper'

class HttpTest < Test::Unit::TestCase
  include TestHelper

  context "default_headers" do
    setup do
      @headers = { "User-Agent" => "Xeroizer/2.15.5" }
      @application = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET, :default_headers => @headers)
    end

    should "recognize default_headers" do
      Xeroizer::OAuth.any_instance.expects(:get).with("/test", has_entry(@headers)).returns(stub(:plain_body => "", :code => "200"))
      @application.http_get(@application.client, "http://example.com/test")
    end
  end
end

