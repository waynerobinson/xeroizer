module Xeroizer
  module Record
    
    class JournalLineTrackingCategoryModel < BaseModel
    
      set_xml_root_name 'TrackingCategories'
      set_xml_node_name 'TrackingCategory'
      
    end
    
    class JournalLineTrackingCategory < Base
      
      string  :name
      string  :option
      guid    :tracking_category_id
      guid    :tracking_option_id
      
    end
    
  end
end
