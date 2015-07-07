module Xeroizer
  module Record
    
    class PhoneModel < BaseModel
            
    end
    
    class Phone < Base
      
      PHONE_TYPE = {
        'DEFAULT' =>    'Default',
        'DDI' =>        'Direct Dial-In',
        'MOBILE' =>     'Mobile',
        'FAX' =>        'Fax'
      } unless defined?(PHONE_TYPE)

      string :phone_type, :internal_name => :type
      string :phone_number, :internal_name => :number
      string :phone_area_code, :internal_name => :area_code
      string :phone_country_code, :internal_name => :country_code

      validates_length_of :phone_number, :max => 50
    end
    
  end
end