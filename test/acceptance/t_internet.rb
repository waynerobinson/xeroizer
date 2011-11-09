class TInternet
  require "oauth"

  def initialize(credential)
    @credential = credential
  end

  def get(url)
    consumer = OAuth::Consumer.new(
	@credential.token,
	@credential.token_secret,
        {
    	  :scheme	=> :header,
          :http_method	=> :get
        }
    )

    auth_header = get_auth_header url, consumer

    get_core(url, {:authorization => auth_header})
  end

  private 

  def get_auth_header(url, consumer)
    request = Net::HTTP::Get.new URI.parse(url).to_s
    
    consumer.options[:signature_method]	= 'HMAC-SHA1'
    consumer.options[:nonce] 		= Time.now.to_i
    consumer.options[:timestamp] 	= Time.now.to_i
    consumer.options[:uri] 		= url
    
    consumer.sign!(request)
    
    request['authorization']
  end

  def get_core(url, headers = {})
    require 'rest_client'

    begin
      RestClient.get url, headers
    rescue => e
      raise e unless e.respond_to?(:response)
      e.response
    end
  end
end
