module Xeroizer
  module Record
    
    class OptionModel < BaseModel
            
    end
    
    class Option < Base
      
      set_primary_key :tracking_option_id
      
      guid   :tracking_option_id
      string :name
      
    end
    
  end
end
