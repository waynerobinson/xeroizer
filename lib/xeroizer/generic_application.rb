module Xeroizer
  class GenericApplication
    
    include Http
    extend Record::ApplicationHelper
    
    attr_reader :client, :xero_url, :logger
    
    extend Forwardable
    def_delegators :client, :access_token
    
    record :Organisation
    record :TrackingCategory
    record :Contact
        
    public
    
      def initialize(consumer_key, consumer_secret, options = {})
        @xero_url = options[:xero_url] || "https://api.xero.com/api.xro/2.0"
        @client   = OAuth.new(consumer_key, consumer_secret, options)
      end
          
  end
end