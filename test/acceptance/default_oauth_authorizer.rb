class DefaultOAuthAuthorizer
  def initialize(credential)
    @credential = credential
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
    consumer.options[:nonce] 		= Time.now.to_i
    consumer.options[:timestamp] 	= Time.now.to_i
    consumer.options[:uri] 		= url

    consumer.sign!(request)

    request['authorization']
  end
end
