module Xeroizer
  class GenericApplication
    
    include Http
    extend Record::ApplicationHelper
    
    attr_reader :client, :xero_url, :logger
    
    extend Forwardable
    def_delegators :client, :access_token
    
    record :Account
    record :BrandingTheme
    record :Contact
    record :CreditNote
    record :Currency
    record :Invoice
    record :Journal
    record :Organisation
    record :Payment
    record :TaxRate
    record :TrackingCategory
    
    public
    
      # Never used directly. Use sub-classes instead.
      # @see PublicApplication
      # @see PrivateApplication
      # @see PartnerApplication
      def initialize(consumer_key, consumer_secret, options = {})
        @xero_url = options[:xero_url] || "https://api.xero.com/api.xro/2.0"
        @client   = OAuth.new(consumer_key, consumer_secret, options)
      end
          
  end
end