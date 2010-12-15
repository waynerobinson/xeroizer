module Xeroizer
  module Record
    
    class CurrencyClass < BaseClass
        
    end
    
    class Currency < Base
      
      string  :code
      string  :description
      
    end
    
  end
end