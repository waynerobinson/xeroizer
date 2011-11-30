class DefaultOAuthAuthorizer
  def initialize(credential, clock)
    @credential = credential
    @clock = clock
  end

  def authorize(request)
    headers = {:authorization => new_auth_header(request.uri, request.verb)}

    Request.new(request.uri, request.verb, headers, nil)
  end

  private

  def new_auth_header(url, verb)
    require "oauth"

    consumer = OAuth::Consumer.new(
	@credential.consumer.key,
	@credential.consumer.secret,
        {
    	  :scheme	=> :header,
          :http_method	=> verb
        }
    )

    request = Net::HTTP::Get.new URI.parse(url).to_s

    consumer.options[:signature_method]	= 'HMAC-SHA1'
    consumer.options[:nonce] 		= @clock.nonce
    consumer.options[:timestamp] 	= @clock.timestamp
    consumer.options[:uri] 		= URI.parse(url)

    consumer.sign!(request, @credential.token)

    request['authorization']
  end
end

CredentialSet = Struct.new("CredentialSet", :consumer, :token)
Credential = Struct.new("Credential", :key, :secret)

Credential.class_eval do
  alias_method :token, :key
end

class Clock
  def timestamp; Time.now.to_i; end
  alias_method :nonce, :timestamp
end
