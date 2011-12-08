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
      end
    end

    def let(symbol, &block)
      return unless block_given?
      define_method symbol, &block
    end
  end

  def setup
    assert_not_nil ENV["CONSUMER_KEY"], "No CONSUMER_KEY environment variable specified."
    assert_not_nil ENV["CONSUMER_SECRET"], "No CONSUMER_SECRET environment variable specified."
    assert_not_nil ENV["KEY_FILE"], "No KEY_FILE environment variable specified."
    assert File.exists?(ENV["KEY_FILE"]), "The file <#{ENV["KEY_FILE"]}> does not exist."
    @key_file = ENV["KEY_FILE"]
    @consumer_key = ENV["CONSUMER_KEY"]
    @consumer_secret = ENV["CONSUMER_SECRET"]
  end
end
