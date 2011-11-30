require File.expand_path File.join(File.dirname(__FILE__), "..", "test_helper")
require "t_internet"
require "default_oauth_authorizer"

class Examples < Test::Unit::TestCase
  def setup
    @credential = CredentialSet.new(
      Credential.new(TestHelper::CONSUMER_KEY, TestHelper::CONSUMER_SECRET),
      nil
    )

    @authorizer = DefaultOAuthAuthorizer.new @credential, Clock.new
  end

  def test_that_you_can_get_a_request_token
    the_url = "https://api.xero.com/oauth/RequestToken"

    response = TInternet.new(@authorizer).get(the_url)

    assert_match /oauth_token=.+&oauth_token_secret=.+&/, response
  end

  def test_can_authorize_an_application
    exchange_url = "https://api.xero.com/oauth/AccessToken"

    the_url = "https://api.xero.com/oauth/RequestToken"

    response = TInternet.new(@authorizer).get(the_url)

    assert_match /oauth_token=.+&oauth_token_secret=.+&/, response

    oauth_token = /oauth_token=([^&]+)/.match(response)[1]
    token_secret = /oauth_token_secret=([^&]+)/.match(response)[1]

    authorize_url = "https://api.xero.com/oauth/Authorize?oauth_token=#{oauth_token}"

    puts "TOKEN_KEY=#{oauth_token}"
    puts "TOKEN_SECRET=#{token_secret}"
    puts "Authorize with this and collect the code: #{authorize_url}"
  end

  def test_can_exchange_tokens
    fail "Missing the <TOKEN_KEY> environment variable" unless ENV["TOKEN_KEY"]
    fail "Missing the <TOKEN_SECRET> environment variable" unless ENV["TOKEN_SECRET"]
    fail "Missing the <VERIFICATION_CODE> environment variable" unless ENV["VERIFICATION_CODE"]

    token = Credential.new ENV["TOKEN_KEY"], ENV["TOKEN_SECRET"]

    exchange_url = "https://api.xero.com/oauth/AccessToken?oauth_verifier=#{ENV["VERIFICATION_CODE"]}"

    credential_set = CredentialSet.new(@credential.consumer, token)

    authorizer = DefaultOAuthAuthorizer.new credential_set, Clock.new

    response = TInternet.new(authorizer).get(exchange_url)

    assert_match "^oauth_token=([^&]+)&oauth_token_secret=([^&]+)", response
  end

  def test_can_connect
    credential_set = CredentialSet.new(
      Credential.new(ENV["CONSUMER_KEY"], ENV["CONSUMER_SECRET"]),
      Credential.new(ENV["TOKEN_KEY"], ENV["TOKEN_SECRET"])
    )

    authorizer = DefaultOAuthAuthorizer.new credential_set, Clock.new

    response = TInternet.new(authorizer).get("https://api.xero.com/api.xro/2.0/Organisation")

    assert_equal 200, response.status
  end

  def test_that_signing_with_just_consumer_works_as_expected
    fake_clock = Class.new do
      def timestamp; "1322618539"; end
      def nonce; "d45a791fad89338ed2987bc548f85a0c"; end
    end

    credentials = CredentialSet.new(Credential.new("key", "secret"), nil)
    authorizer = DefaultOAuthAuthorizer.new credentials, fake_clock.new

    request = Request.new "http://xxx/", "GET"

    authorized = authorizer.authorize request

    the_signature = URI.decode(/oauth_signature=([^&]+)/.match(authorized.headers[:authorization])[1])

    assert_match "Bzst8dFBg4QgeWj+HCJIv9nbXm0=", the_signature
  end

  def test_that_signing_with_token_works_as_expected
    fake_clock = Class.new do
      def timestamp; "1322618944"; end
      def nonce; "1d273ba4d393249988456762f9bc3d11"; end
    end

    credentials = CredentialSet.new(
      Credential.new("key", "secret"),
      Credential.new("token_key", "token_secret")
    )
    authorizer = DefaultOAuthAuthorizer.new credentials, fake_clock.new

    request = Request.new "http://xxx/", "GET"

    authorized = authorizer.authorize request

    the_signature = URI.decode(/oauth_signature=([^&]+)/.match(authorized.headers[:authorization])[1])

    assert_match "zp/rDYa5E2LY8SFVVTSusRAgxDk=", the_signature
  end
end
