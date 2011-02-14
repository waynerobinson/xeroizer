module Xeroizer
  module Record
    
    class ItemPurchaseSaleDetailsModel < BaseModel
        
    end
    
    class ItemPurchaseSaleDetails < Base
      
      decimal :unit_price
      string  :account_code
      string  :tax_type
       
    end
    
  end
end