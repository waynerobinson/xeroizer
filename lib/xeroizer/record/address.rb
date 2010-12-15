module Xeroizer
  module Record
    
    class AddressClass < BaseClass
            
    end
    
    class Address < Base
      
      ADDRESS_TYPE = {
        'STREET' =>     'Street',
        'POBOX' =>      'PO Box',
        'DEFAULT' =>    'Default address type'
      } unless defined?(ADDRESS_TYPE)
      
      string :address_type, :internal_name => :type
      string :address_line1, :internal_name => :line1
      string :address_line2, :internal_name => :line2
      string :address_line3, :internal_name => :line3
      string :address_line4, :internal_name => :line4
      string :city
      string :region
      string :postal_code
      string :country
      
    end
    
  end
end