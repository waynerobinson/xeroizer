module Xeroizer
  module Record
    
    class TrackingCategoryModel < BaseModel
      
      set_api_controller_name 'TrackingCategory'
      set_permissions :read
                  
    end
    
    class TrackingCategory < Base
      
      string :tracking_category_id, :api_name => 'TrackingCategoryID'
      string :name
      string :status
      
      has_many :options
      
    end
    
  end
end