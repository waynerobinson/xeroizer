module Xeroizer
  class PartnerApplication < GenericApplication
    
    extend Forwardable
    def_delegators :client, :request_token, :authorize_from_request, :renew_access_token, :expires_at, :authorization_expires_at, :session_handle
    
    public
    
      def initialize(consumer_key, consumer_secret, path_to_private_key, path_to_ssl_client_cert, path_to_ssl_client_key, options = {})
        options.merge!(
          :xero_url => 'https://api-partner.network.xero.com/api.xro/2.0',
          :site => 'https://api-partner.network.xero.com',
          :authorize_url => 'https://api.xero.com/oauth/Authorize',      
          :signature_method => 'RSA-SHA1',
          :private_key_file => path_to_private_key,
          :ssl_client_cert => OpenSSL::X509::Certificate.new(File.read(path_to_ssl_client_cert)),
          :ssl_client_key => OpenSSL::PKey::RSA.new(path_to_ssl_client_key)
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
    
  end
end