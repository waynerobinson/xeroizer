module Xeroizer
  module Record
    
    class ContactPurchasesTrackingCategoryModel < BaseModel
    
      set_xml_root_name 'PurchasesTrackingCategories'
      set_xml_node_name 'PurchasesTrackingCategory'
      
    end
    
    class ContactPurchasesTrackingCategory < Base
      
      string  :tracking_category_name
      string  :tracking_option_name
      
    end
    
  end
end