require "test_helper"

class OAuthConfigTest < Test::Unit::TestCase
  include Xeroizer

  must "load oauth configuration from yaml" do
    the_yaml = "
    consumer:
        key: key
        secret: secret
        key_file: key_file
    "

    result = OAuthConfig.load the_yaml

    assert_equal "key",      result.consumer_key,    "Unexpected consumer_key value"
    assert_equal "secret",   result.consumer_secret, "Unexpected consumer_secret value"
    assert_equal "key_file", result.key_file,        "Unexpected key_file value"
  end
end
