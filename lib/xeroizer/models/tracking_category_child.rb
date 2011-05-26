module Xeroizer
  module Record
    
    class TrackingCategoryChildModel < BaseModel
    
      set_xml_root_name 'Tracking'
      set_xml_node_name 'TrackingCategory'
      
    end
    
    class TrackingCategoryChild < Base
      
      string  :name
      string  :option
      guid    :tracking_category_id
      
    end
    
  end
end