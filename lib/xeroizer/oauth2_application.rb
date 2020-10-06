module Xeroizer
  class OAuth2Application < GenericApplication

    extend Forwardable
    def_delegators :client,
                   :authorize_from_access,
                   :authorize_from_code,
                   :authorize_url,
                   :renew_access_token,
                   :tenant_id,
                   :tenant_id=

    public

    # OAuth2 applications allow for connecting to Xero over OAuth2, as opposed to the
    # Partner and Private applications which talk over OAuth1.
    #
    # @param [String] client_id client id/token from application developer (found at http://api.xero.com for your application).
    # @param [String] client_secret client secret from application developer (found at http://api.xero.com for your application).
    # @param [Hash] options other options to pass to the GenericApplication constructor
    # @return [OAuth2Application] instance of OAuth2Application
    def initialize(client_id, client_secret, options = {})
      default_options = {
        :xero_url         => 'https://api.xero.com/api.xro/2.0',
        :site             => 'https://api.xero.com',
        :authorize_url    => 'https://login.xero.com/identity/connect/authorize',
        :token_url        => 'https://identity.xero.com/connect/token',
        :tenets_url       => 'https://api.xero.com/connections',
        :raise_errors     => false
      }
      options = default_options.merge(options)
      client = OAuth2.new(client_id, client_secret, options)
      super(client, options)

      if options[:access_token]
        authorize_from_access(options[:access_token], options)
      end

      if options[:tenant_id]
        client.tenant_id = options[:tenant_id]
      end
    end

    def current_connections
      Connection.current_connections(client)
    end
  end
end
