module Xeroizer
  
  # Shamelessly taken from the XeroGateway library by Tim Connor which is shamelessly 
  # based on the Twitter Gem's OAuth implementation by John Nunemaker
  # Thanks!
  # 
  # http://github.com/tlconnor/xero_gateway
  # http://twitter.rubyforge.org/
  # http://github.com/jnunemaker/twitter/
  
  class OAuth
    
    class TokenExpired < StandardError; end
    class TokenInvalid < StandardError; end
    class RateLimitExceeded < StandardError; end
    class UnknownError < StandardError; end
        
    unless defined? XERO_CONSUMER_OPTIONS
      XERO_CONSUMER_OPTIONS = {
        :site               => "https://api.xero.com",
        :request_token_path => "/oauth/RequestToken",
        :access_token_path  => "/oauth/AccessToken",
        :authorize_path     => "/oauth/Authorize",
        :ca_file            => File.expand_path(File.join(File.dirname(__FILE__), 'ca-certificates.crt'))
      }.freeze
    end
    
    # Mixin real OAuth methods for consumer.
    extend Forwardable
    def_delegators :access_token, :get, :post, :put, :delete
    
    attr_reader :ctoken, :csecret, :consumer_options, :expires_in, :authorization_expires_in, :session_handle
    
    def initialize(ctoken, csecret, options = {})
      @ctoken, @csecret = ctoken, csecret
      @consumer_options = XERO_CONSUMER_OPTIONS.merge(options)
    end
    
    # OAuth consumer creator.
    def consumer
      @consumer ||= create_consumer
    end
    
    # RequestToken for PUBLIC/PARTNER authorisation 
    # (used to redirect to Xero for authentication).
    def request_token(params = {})
      @request_token ||= consumer.get_request_token(params)
    end
    
    # Create an AccessToken from a PUBLIC/PARTNER authorisation.
    def authorize_from_request(rtoken, rsecret, params = {})
      request_token = ::OAuth::RequestToken.new(consumer, rtoken, rsecret)
      access_token = request_token.get_access_token(params)
      update_attributes_from_token(access_token)
    end
    
    # AccessToken created from authorize_from_access method.
    def access_token
      @access_token ||= ::OAuth::AccessToken.new(consumer, @atoken, @asecret)
    end
    
    # Used for PRIVATE applications where the AccessToken uses the 
    # token/secret from Xero which would normally be used in the request.
    # No request authorisation necessary.
    def authorize_from_access(atoken, asecret)
      @atoken, @asecret = atoken, asecret
    end
    
    # Renew an access token from a previously authorised token for a
    # PARTNER application.
    def renew_access_token(atoken = nil, asecret = nil, session_handle = nil)
      old_token = ::OAuth::RequestToken.new(consumer, atoken || @atoken, asecret || @secret)
      access_token = old_token.get_access_token({
        :oauth_session_handle => (session_handle || @session_handle), 
        :token => old_token
      })
      update_attributes_from_token(access_token)
    end
    
    private 
    
      def create_consumer
        consumer = ::OAuth::Consumer.new(@ctoken, @csecret, consumer_options)
        if @consumer_options[:ssl_client_cert] && @consumer_options[:ssl_client_key]
          consumer.http.cert = @consumer_options[:ssl_client_cert]
          consumer.http.key = @consumer_options[:ssl_client_key]
        end
        consumer
      end
      
      def update_attributes_from_token(access_token)
        @expires_in = access_token.params[:oauth_expires_in]
        @authorization_expires_in = access_token.params[:oauth_authorization_expires_in]
        @session_handle = access_token.params[:oauth_session_handle]
        @atoken, @asecret = access_token.token, access_token.secret
      end
          
  end
end
