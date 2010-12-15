module Xeroizer
  class PrivateApplication < GenericApplication
    
    extend Forwardable
    def_delegators :client, :authorize_from_access

    public
    
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