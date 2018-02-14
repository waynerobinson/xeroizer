module Xeroizer
  module Record
    
    class CurrencyModel < BaseModel
        
      set_permissions :read, :write

      # Currencies can only be created (added), no update or delete is possible
      def create_method
        :http_put
      end
      
    end
    
    class Currency < Base

      # Currency does not have an ID
      # This method overrides the base model to always treat a Currency as new (so it can be saved)
      # Attempting to update a currency will result in a validation error.	
      def new_record?
      	true
      end
      
      string  :code
      string  :description # read only
      
    end
    
  end
end