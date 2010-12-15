module Xeroizer
  module Record
    
    class TrackingCategoryClass < BaseClass
            
    end
    
    class TrackingCategory < Base
      
      string :tracking_category_id
      string :name
      has_many :options
      
    end
    
  end
end