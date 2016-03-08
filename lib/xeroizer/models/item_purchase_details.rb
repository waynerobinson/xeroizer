module Xeroizer
  module Record
    
    class ItemPurchaseDetailsModel < BaseModel
        
      set_xml_node_name 'PurchaseDetails'
        
    end
    
    class ItemPurchaseDetails < Base
      
      decimal :unit_price
      string  :account_code
      string  :tax_type
      decimal :cogs_account_code

    end
    
  end
end