module Xeroizer
  class OAuth2Application < GenericApplication

    extend Forwardable
    def_delegators :client, :authorize_from_access, :tenant_id, :tenant_id=

    public

    # Partner applications allow for public AccessToken's received via the stanard OAuth
    # authentication process to be renewed up until the session's expiry. The default session
    # expiry for Xero is 365 days and the default AccessToken expiry is 30 minutes.
    #
    # @param [String] consumer_key consumer key/token from application developer (found at http://api.xero.com for your application).
    # @param [String] consumer_secret consumer secret from application developer (found at http://api.xero.com for your application).
    # @param [String] path_to_private_key application's private key for message signing (uploaded to http://api.xero.com)
    # @param [Hash] options other options to pass to the GenericApplication constructor
    # @return [PartnerApplication] instance of PrivateApplication
    def initialize(client_key, client_secret, options = {})
      default_options = {
        :xero_url         => 'https://api.xero.com/api.xro/2.0',
        :site             => 'https://api.xero.com',
        :authorize_url    => 'https://login.xero.com/identity/connect/authorize',
        :token_url        => 'https://identity.xero.com/connect/token',
        :tenets_url       => 'https://api.xero.com/connections',
      }
      options = default_options.merge(options)
      client = OAuth2.new(client_key, client_secret, options)
      super(client, options)

      if options[:access_token]
        authorize_from_access(options[:access_token], options)
      end

      if options[:tenant_id]
        tenant_id = options[:tenant_id]
      end
    end
  end
end
