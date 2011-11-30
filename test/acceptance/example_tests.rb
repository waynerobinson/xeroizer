require File.expand_path File.join(File.dirname(__FILE__), "..", "test_helper")
require "t_internet"
require "default_oauth_authorizer"

CredentialSet = Struct.new("CredentialSet", :consumer, :token)
Credential = Struct.new("Credential", :key, :secret)

class Examples < Test::Unit::TestCase
  def setup
    @credential = CredentialSet.new(
      Credential.new(TestHelper::CONSUMER_KEY, TestHelper::CONSUMER_SECRET),
      nil
    )

    @authorizer = DefaultOAuthAuthorizer.new @credential
  end

  def test_that_you_can_get_a_request_token
    the_url = "https://api.xero.com/oauth/RequestToken"

    response = TInternet.new(@authorizer).get(the_url)

    assert_match /oauth_token=.+&oauth_token_secret=.+&/, response
  end

  def test_generating_authorize_url
    the_url = "https://api.xero.com/oauth/RequestToken"

    response = TInternet.new(@authorizer).get(the_url)

    assert_match /oauth_token=.+&oauth_token_secret=.+&/, response

    oauth_token = /oauth_token=([^&]+)/.match(response)[1]

    authorize_url = "https://api.xero.com/oauth/Authorize?oauth_token=#{oauth_token}"

    puts authorize_url
  end

  def test_can_exchange_tokens
    exchange_url = "https://api.xero.com/oauth/AccessToken"
  end

 # 8929122
end
