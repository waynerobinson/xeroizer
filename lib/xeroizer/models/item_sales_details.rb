module Xeroizer
  module Record
    
    class ItemSalesDetailsModel < BaseModel
        
      set_xml_node_name 'SalesDetails'
        
    end
    
    class ItemSalesDetails < Base
      
      decimal :unit_price
      string  :account_code
      string  :tax_type
       
    end
    
  end
end
