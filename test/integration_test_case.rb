require 'test_helper'
require 'vcr_setup'

# Base class for integration tests. Each test replays a recorded Xero API
# interaction (a "cassette" under test/fixtures/vcr_cassettes/), so the suite
# runs in CI with no credentials. See test/integration/README.md for how to
# record, refresh, and add tests.
class IntegrationTestCase < Minitest::Test
  # Wrap the whole test (setup included — several tests fetch in setup) in a
  # cassette named after the class and test method.
  def run(*)
    VCR.use_cassette(cassette_name) { super }
  end

  # Live client when XERO_* env vars are set (recording), fake credentials
  # otherwise (replay matches on method+URI, so the token is irrelevant).
  def oauth2_client
    self.class.oauth2_client
  end

  class << self
    def oauth2_client
      Xeroizer::OAuth2Application.new(
        TestHelper::CLIENT_ID, TestHelper::CLIENT_SECRET,
        access_token: TestHelper::ACCESS_TOKEN, tenant_id: TestHelper::TENANT_ID
      )
    end

    def it_works_using_oauth2(&)
      instance_exec(oauth2_client, 'oauth2', &)
    end

    def log_to_console
      Xeroizer::Logging.const_set :Log, Xeroizer::Logging::StdOutLog
    end

    def no_log
      Xeroizer::Logging.const_set :Log, Xeroizer::Logging::DevNullLog
    end

    def let(symbol, &block)
      return unless block_given?
      return if respond_to?(symbol)

      define_method symbol do
        ivar = "@#{symbol}"
        cached = instance_variable_get(ivar)
        instance_variable_set(ivar, instance_eval(&block)) if cached.nil?
        instance_variable_get(ivar)
      end
    end
  end

  private

  def cassette_name
    "#{self.class.name}/#{name.gsub(/[^0-9A-Za-z_-]+/, '_').gsub(/\A_+|_+\z/, '')}"
  end
end
