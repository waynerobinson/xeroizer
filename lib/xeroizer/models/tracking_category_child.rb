module Xeroizer
  module Record
    
    class TrackingCategoryChildModel < BaseModel
                  
    end
    
    class TrackingCategoryChild < Base
      
      string  :name
      string  :option
      guid    :tracking_category_id
      
    end
    
  end
end