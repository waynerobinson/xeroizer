module Xeroizer
  module Record
    
    class PhoneClass < BaseClass
            
    end
    
    class Phone < Base

      string :phone_type, :internal_name => :type
      string :phone_number, :internal_name => :number
      string :phone_area_code, :internal_name => :area_code
      string :phone_country_code, :internal_name => :country_code
      
    end
    
  end
end