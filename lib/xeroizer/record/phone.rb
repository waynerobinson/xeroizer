module Xeroizer
  module Record
    
    class PhoneClass < BaseClass
            
    end
    
    class Phone < Base

      string :phone_type
      string :phone_number
      string :phone_area_code
      string :phone_country_code
      
    end
    
  end
end