require "test_helper"

# Base class for integration tests. They call the Xero API and are skipped
# without credentials. See test/integration/README.md.
class IntegrationTestCase < Minitest::Test
  CREDENTIALS = %w[XERO_CLIENT_ID XERO_CLIENT_SECRET XERO_ACCESS_TOKEN XERO_TENANT_ID].freeze
  MISSING_CREDENTIALS = CREDENTIALS.select { |key| ENV[key].to_s.empty? }

  # A hook rather than setup, because several tests define setup without super.
  def before_setup
    skip "Set #{MISSING_CREDENTIALS.join(', ')} to run against Xero" if MISSING_CREDENTIALS.any?
    super
  end

  def self.oauth2_client
    Xeroizer::OAuth2Application.new(
      ENV.fetch("XERO_CLIENT_ID"),
      ENV.fetch("XERO_CLIENT_SECRET"),
      access_token: ENV.fetch("XERO_ACCESS_TOKEN"),
      tenant_id: ENV.fetch("XERO_TENANT_ID")
    )
  end

  def oauth2_client
    self.class.oauth2_client
  end
end

if IntegrationTestCase::MISSING_CREDENTIALS.empty?
  begin
    org = IntegrationTestCase.oauth2_client.Organisation.first
  rescue StandardError => e
    abort "Cannot reach Xero (#{e.class}: #{e.message})."
  end
  abort "The integration tests write data into Xero; #{org.name} is not a Demo Company." unless org.is_demo_company
end
