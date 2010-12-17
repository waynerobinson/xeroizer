module Xeroizer
  module Record
    
    class CurrencyModel < BaseModel
        
      set_permissions :read
      
    end
    
    class Currency < Base
      
      string  :code
      string  :description
      
    end
    
  end
end