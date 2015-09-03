module Xeroizer
  class PrivateApplication < GenericApplication

    extend Forwardable
    def_delegators :client, :authorize_from_access

    public

      # Private applications are defined in the Xero API website and can be accessed in the
      # background without ever requiring a redirect to the Xero website for authorisation.
      #
      # @param [String] consumer_key consumer key/token from application developer (found at http://api.xero.com for your application).
      # @param [String] consumer_secret consumer secret from application developer (found at http://api.xero.com for your application).
      # @param [String] path_to_private_key application's private key for message signing (uploaded to http://api.xero.com)
      # @param [Hash] options other options to pass to the GenericApplication constructor
      # @return [PrivateApplication] instance of PrivateApplication
      def initialize(consumer_key, consumer_secret, path_to_private_key, options = {})
        options.merge!(
          :signature_method => 'RSA-SHA1',
          :private_key_file => path_to_private_key
        )
        super(consumer_key, consumer_secret, options)
        @client.authorize_from_access(consumer_key, consumer_secret)
      end

  end
end
