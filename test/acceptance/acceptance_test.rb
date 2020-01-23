module AcceptanceTestHelpers
  def self.oauth_client
    config = load_config_from_file || load_config_from_env
    Xeroizer::PrivateApplication.new(config.consumer_key, config.consumer_secret, config.key_file)
  end

  def self.oauth2_client
    config = self.load_oauth2_config_from_env
    Xeroizer::OAuth2Application.new(
      config.client_id,
      config.client_secret,
      access_token: config.access_token,
      tenant_id: config.tenant_id
    )
  end

  def self.load_config_from_file
    the_file_name = File.join(File.dirname(__FILE__), '..', '..', '.oauth')

    return nil unless File.exist? the_file_name

    Xeroizer::OAuthConfig.load IO.read the_file_name
  end

  def self.load_config_from_env
    raise "No CONSUMER_KEY environment variable specified." unless ENV["CONSUMER_KEY"]
    raise "No CONSUMER_SECRET environment variable specified." unless ENV["CONSUMER_SECRET"]
    raise "No PRIVATE_KEY_PATH environment variable specified." unless ENV["PRIVATE_KEY_PATH"]
    raise "The file <#{ENV["PRIVATE_KEY_PATH"]}> does not exist." unless File.exist?(ENV["PRIVATE_KEY_PATH"])
    Xeroizer::OAuthCredentials.new ENV["CONSUMER_KEY"], ENV["CONSUMER_SECRET"], ENV["PRIVATE_KEY_PATH"]
  end

  def self.load_oauth2_config_from_env
    raise "No XERO_CLIENT_ID environment variable specified." unless ENV["XERO_CLIENT_ID"]
    raise "No XERO_CLIENT_SECRET environment variable specified." unless ENV["XERO_CLIENT_SECRET"]
    raise "No XERO_ACCESS_TOKEN environment variable specified." unless ENV["XERO_ACCESS_TOKEN"]
    raise "No XERO_TENANT_ID environment variable specified." unless ENV["XERO_TENANT_ID"]

    OpenStruct.new(client_id: ENV["XERO_CLIENT_ID"],
      client_secret: ENV["XERO_CLIENT_SECRET"],
      access_token: ENV["XERO_ACCESS_TOKEN"],
      tenant_id: ENV["XERO_TENANT_ID"])
  end
end

module AcceptanceTest
  class << self
    def included(klass)
      klass.class_eval do
        def self.it_works_using_oauth1_and_oauth2(&block)
          instance_exec(AcceptanceTestHelpers.oauth_client, 'oauth', &block)
          instance_exec(AcceptanceTestHelpers.oauth2_client, 'oauth2', &block)
        end

        def self.log_to_console
          Xeroizer::Logging.const_set :Log, Xeroizer::Logging::StdOutLog
        end

        def self.no_log
          Xeroizer::Logging.const_set :Log, Xeroizer::Logging::DevNullLog
        end

        def self.let(symbol, &block)
          return unless block_given?

          unless respond_to? symbol
            define_method symbol do
              cached_method_result = instance_variable_get ivar_name = "@#{symbol}"
              instance_variable_set(ivar_name, instance_eval(&block)) if cached_method_result.nil?
              instance_variable_get ivar_name
            end
          end
        end
      end
    end
  end
end
