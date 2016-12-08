# Copyright (c) 2008 Tim Connor <tlconnor@gmail.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

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
    class ConsumerKeyUnknown < StandardError; end
    class NonceUsed < StandardError; end
    class UnknownError < StandardError; end

    unless defined? XERO_CONSUMER_OPTIONS
      XERO_CONSUMER_OPTIONS = {
        :site               => "https://api.xero.com",
        :request_token_path => "/oauth/RequestToken",
        :access_token_path  => "/oauth/AccessToken",
        :authorize_path     => "/oauth/Authorize",
        #:ca_file            => File.expand_path(File.join(File.dirname(__FILE__), 'ca-certificates.crt'))
      }.freeze
    end

    # Mixin real OAuth methods for consumer.
    extend Forwardable
    def_delegators :access_token, :get, :post, :put, :delete

    # @attr_reader [String] ctoken consumer key/token from application developer (found at http://api.xero.com for your application).
    # @attr_reader [String] csecret consumer secret from application developer (found at http://api.xero.com for your application).
    # @attr_reader [Time] expires_at time the AccessToken expires if using the PartnerApplication mode (usually 30 minutes for Xero).
    # @attr_reader [Time] authorization_expires_at time the session expires if using the ParnterApplication mode (usually 365 days for Xero).
    attr_reader :ctoken, :csecret, :consumer_options, :expires_at, :authorization_expires_at

    # @attr_reader [String] session_handle session handle used to renew AccessToken if using the PartnerApplication mode.
    # @attr_writer [String] session_handle session handle used to renew AccessToken if using the PartnerApplication mode.
    attr_accessor :session_handle

    # OAuth constructor.
    #
    # @param [String] ctoken consumer key/token from application developer (found at http://api.xero.com for your application).
    # @param [String] csecret consumer secret from application developer (found at http://api.xero.com for your application).
    # @option options [String] :access_token_path base URL path for getting an AccessToken (default: "/oauth/AccessToken")
    # @option options [String] :authorize_path base URL path for authorising (default: "/oauth/Authorize")
    # @option options [String] :ca_file file containing SSL root certificates (default: "lib/xeroizer/ca-certificates.crt")
    # @option options [String] :private_key_file private key used when :signature_method set to RSA-SHA1 (used for PartnerApplication and PrivateApplication modes)
    # @option options [String] :request_token_path base URL path for getting a RequestToken (default: "/oauth/RequestToken")
    # @option options [String] :signature_method method usd to sign requests (default: OAuth library default)
    # @option options [String] :site base site for API requests (default: "https://api.xero.com")
    # @option options [IO] :http_debug_output filehandle to write HTTP traffic to
    # @option options [OpenSSL:X509::Certificate] :ssl_client_cert client-side SSL certificate to use for requests (used for PartnerApplication mode)
    # @option options [OpenSSL::PKey::RSA] :ssl_client_key client-side SSL private key to use for requests (used for PartnerApplication mode)
    def initialize(ctoken, csecret, options = {})
      @ctoken, @csecret = ctoken, csecret
      @consumer_options = XERO_CONSUMER_OPTIONS.merge(options)
    end

    # OAuth consumer creator.
    #
    # @return [OAuth::Consumer] consumer object for GET/POST/PUT methods.
    def consumer
      create_consumer
    end

    # RequestToken for PUBLIC/PARTNER authorisation
    # (used to redirect to Xero for authentication).
    #
    # @option params [String] :oauth_callback URL to redirect user to when they have authenticated your application with Xero. If not specified, the user will be shown an authorisation code on the screen that they need to get into your application.
    def request_token(params = {})
      consumer.get_request_token(params, {}, @consumer_options[:default_headers])
    end

    # Create an AccessToken from a PUBLIC/PARTNER authorisation.
    def authorize_from_request(rtoken, rsecret, params = {})
      request_token = ::OAuth::RequestToken.new(consumer, rtoken, rsecret)
      access_token = request_token.get_access_token(params, {}, @consumer_options[:default_headers])
      update_attributes_from_token(access_token)
    end

    # AccessToken created from authorize_from_access method.
    def access_token
      ::OAuth::AccessToken.new(consumer, @atoken, @asecret)
    end

    # Used for PRIVATE applications where the AccessToken uses the
    # token/secret from Xero which would normally be used in the request.
    # No request authorisation necessary.
    #
    # For PUBLIC/PARTNER applications this is used to recreate a client
    # from a stored AccessToken key/secret.
    def authorize_from_access(atoken, asecret)
      @atoken, @asecret = atoken, asecret
    end

    # Renew an access token from a previously authorised token for a
    # PARTNER application.
    def renew_access_token(atoken = nil, asecret = nil, session_handle = nil)
      old_token = ::OAuth::RequestToken.new(consumer, atoken || @atoken, asecret || @asecret)
      access_token = old_token.get_access_token({
        :oauth_session_handle => (session_handle || @session_handle),
        :token => old_token
      }, {}, @consumer_options[:default_headers])
      update_attributes_from_token(access_token)
    end

    private

      # Create an OAuth consumer with the SSL client key if specified in @consumer_options when
      # this instance was created.
      def create_consumer
        consumer = ::OAuth::Consumer.new(@ctoken, @csecret, consumer_options)
        if @consumer_options[:ssl_client_cert] && @consumer_options[:ssl_client_key]
          consumer.http.cert = @consumer_options[:ssl_client_cert]
          consumer.http.key = @consumer_options[:ssl_client_key]
        end
        consumer

        if @consumer_options[:http_debug_output]
          consumer.http.set_debug_output(@consumer_options[:http_debug_output])
        end
        consumer
      end

      # Update instance variables with those from the AccessToken.
      def update_attributes_from_token(access_token)
        @expires_at = Time.now + access_token.params[:oauth_expires_in].to_i
        @authorization_expires_at = Time.now + access_token.params[:oauth_authorization_expires_in].to_i
        @session_handle = access_token.params[:oauth_session_handle]
        @atoken, @asecret = access_token.token, access_token.secret
      end
  end
end
