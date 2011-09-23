module Xeroizer
  module Record
    
    class ItemSaleDetailsModel < BaseModel
        
      set_xml_node_name 'SaleDetails'
        
    end
    
    class ItemSaleDetails < Base
      
      decimal :unit_price
      string  :account_code
      string  :tax_type
       
    end
    
  end
end