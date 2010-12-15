module Xeroizer
  module Record
    
    class PhoneClass < BaseClass
            
    end
    
    class Phone < Base

      string :phone_type, :type
      string :phone_number, :number
      string :phone_area_code, :area_code
      string :phone_country_code, :country_code
      
    end
    
  end
end