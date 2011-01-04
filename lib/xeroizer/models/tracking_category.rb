module Xeroizer
  module Record
    
    class TrackingCategoryModel < BaseModel
      
      set_api_controller_name 'TrackingCategory'
      set_permissions :read
                  
    end
    
    class TrackingCategory < Base
      
      set_primary_key :tracking_category_id
      
      guid   :tracking_category_id
      string :name
      string :status
      
      has_many :options
      
    end
    
  end
end