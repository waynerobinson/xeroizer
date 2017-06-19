module Xeroizer
  class PartnerApplication < GenericApplication

    extend Forwardable
    def_delegators :client, :request_token, :authorize_from_request, :renew_access_token, :expires_at, :authorization_expires_at, :session_handle, :authorize_from_access

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
      def initialize(consumer_key, consumer_secret, path_to_private_key, options = {})
        default_options = {
          :xero_url         => 'https://api.xero.com/api.xro/2.0',
          :site             => 'https://api.xero.com',
          :authorize_url    => 'https://api.xero.com/oauth/Authorize',
          :signature_method => 'RSA-SHA1'
        }
        options = default_options.merge(options).merge(
          :private_key_file => path_to_private_key
        )
        super(consumer_key, consumer_secret, options)

        # Load up an existing token if passed the token/key.
        if options[:access_token] && options[:access_key]
          authorize_from_access(options[:access_token], options[:access_key])
        end

        # Save the session_handle if passed in so we can renew the token.
        if options[:session_handle]
          client.session_handle = options[:session_handle]
        end
      end

    private

      def read_certificate(cert)
        if File.exists?(cert)
          File.read(cert)
        else
          cert
        end
      end
  end
end
