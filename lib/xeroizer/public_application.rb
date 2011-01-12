module Xeroizer
  class PublicApplication < GenericApplication
    
    extend Forwardable
    def_delegators :client, :request_token, :authorize_from_request, :authorize_from_access

    public
    
      # Public appliations are authenticated via the Xero website via OAuth. AccessTokens are valid for 30 minutes
      # after authentication. To extend this time you must redirect the user to Xero's OAuth server again.
      # 
      # @param [String] consumer_key consumer key/token from application developer (found at http://api.xero.com for your application)
      # @param [String] consumer_secret consumer secret from application developer (found at http://api.xero.com for your application)
      # @param [Hash] options other options to pass to the GenericApplication constructor
      # @return [PublicApplication] instance of PrivateApplication
      def initialize(consumer_key, consumer_secret, options = {})
        super(consumer_key, consumer_secret, options)
      end

  end
end
