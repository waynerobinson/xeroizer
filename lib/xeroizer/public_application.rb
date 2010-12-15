module Xeroizer
  class PublicApplication < GenericApplication
    
    extend Forwardable
    def_delegators :client, :request_token, :authorize_from_request

    public
    
      def initialize(consumer_key, consumer_secret, options = {})
        super(consumer_key, consumer_secret, options)
      end

  end
end
