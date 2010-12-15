module Xeroizer
  class Response
    
    attr_accessor :id, :status, :errors, :provider, :date_time, :response_items, :request_params, :request_xml, :response_xml
    
    public
    
      def success?
        status == 'OK'
      end
      
      def error
        errors.blank? ? nil : errors[0]
      end
      
  end
end