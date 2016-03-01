module Xeroizer
  module Record
    
    class ContactSalesTrackingCategoryModel < BaseModel
    
      set_xml_root_name 'SalesTrackingCategories'
      set_xml_node_name 'SalesTrackingCategory'
      
    end
    
    class ContactSalesTrackingCategory < Base
      
      string  :tracking_category_name
      string  :tracking_option_name
      
    end
    
  end
end