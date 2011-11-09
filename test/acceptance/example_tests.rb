require File.expand_path File.join(File.dirname(__FILE__), "..", "test_helper")
require "t_internet"

Credential = Struct.new("Credential", :token, :token_secret)

class Examples < Test::Unit::TestCase
  def setup
    credentials_okay = TestHelper::CONSUMER_SECRET && TestHelper::CONSUMER_KEY
    fail "Missing required environment variables CONSUMER_KEY and CONSUMER_SECRET." unless credentials_okay
  end

  def test_that_you_can_get_a_request_token
    the_url    = "https://api.xero.com/oauth/RequestToken"
    
    credential = Credential.new(TestHelper::CONSUMER_KEY, TestHelper::CONSUMER_SECRET)

    response = TInternet.new(credential).get(the_url)

    assert_match /oauth_token=.+&oauth_token_secret=.+&/, response
  end
end
