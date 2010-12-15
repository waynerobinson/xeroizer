module Xeroizer
  module Record
    
    class TrackingCategoryClass < BaseClass
      
      set_api_controller_name 'TrackingCategory'
            
    end
    
    class TrackingCategory < Base
      
      string :tracking_category_id
      string :name
      has_many :options
      
    end
    
  end
end