module AcceptanceTest
  class << self
    def included(klass)
      klass.class_eval do
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

  def setup
    config = load_config_from_file || load_config_from_env

    @key_file = config.key_file
    @consumer_key = config.consumer_key
    @consumer_secret = config.consumer_secret
  end

  private

  def load_config_from_file
    the_file_name = File.join(File.dirname(__FILE__), '..', '..', '.oauth')

    return nil unless File.exists? the_file_name

    Xeroizer::OAuthConfig.load IO.read the_file_name
  end

  def load_config_from_env
    assert_not_nil ENV["CONSUMER_KEY"], "No CONSUMER_KEY environment variable specified."
    assert_not_nil ENV["CONSUMER_SECRET"], "No CONSUMER_SECRET environment variable specified."
    assert_not_nil ENV["KEY_FILE"], "No KEY_FILE environment variable specified."
    assert File.exists?(ENV["KEY_FILE"]), "The file <#{ENV["KEY_FILE"]}> does not exist."
    Xeroizer::OAuthCredentials.new ENV["CONSUMER_KEY"], ENV["CONSUMER_SECRET"], ENV["KEY_FILE"]
  end
end
