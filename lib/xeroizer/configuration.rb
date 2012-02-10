module Xeroizer
  OAuthCredentials = Struct.new "OAuthCredentials", :consumer_key, :consumer_secret, :key_file

  class OAuthConfig
    class << self
      def load yaml_text
        require "yaml"
        yaml = YAML.load yaml_text
        consumer_credential = yaml["consumer"]

        OAuthCredentials.new(
          consumer_credential["key"],
          consumer_credential["secret"],
          consumer_credential["key_file"]
        )
      end
    end
  end
end
