module Xeroizer
  module Record
    
    class CurrencyClass < BaseClass
        
      set_permissions :read
      
    end
    
    class Currency < Base
      
      string  :code
      string  :description
      
    end
    
  end
end