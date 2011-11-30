require File.expand_path File.join(File.dirname(__FILE__), "..", "test_helper")
require "t_internet"
require "default_oauth_authorizer"

class AboutPrivateApplications < Test::Unit::TestCase
  def setup
    assert_not_nil ENV["CONSUMER_KEY"], "No CONSUMER_KEY environment variable specified."
    assert_not_nil ENV["CONSUMER_SECRET"], "No CONSUMER_SECRET environment variable specified."
    assert_not_nil ENV["KEY_FILE"], "No KEY_FILE environment variable specified."
    assert File.exists?(ENV["KEY_FILE"]), "The file <#{ENV["KEY_FILE"]}> does not exist."
    @key_file = ENV["KEY_FILE"]
    @consumer_key = ENV["CONSUMER_KEY"]
    @consumer_secret = ENV["CONSUMER_SECRET"]
  end

  def test_that_you_can_connect
    client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)

    assert(client.Contact.all.size > 0, "Expected at least one contact")
  end
end
