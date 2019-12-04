module Xeroizer
  module Record

    class AddressModel < BaseModel

    end

    class Address < Base

      ADDRESS_TYPE = {
        'STREET' =>     'Street',
        'POBOX' =>      'PO Box',
        'DEFAULT' =>    'Default address type'
      } unless defined?(ADDRESS_TYPE)

      string :address_type, :internal_name => :type
      string :attention_to
      string :address_line1, :internal_name => :line1
      string :address_line2, :internal_name => :line2
      string :address_line3, :internal_name => :line3
      string :address_line4, :internal_name => :line4
      string :city
      string :region
      string :postal_code
      string :country
      string :addressLine1, api_name: 'addressLine1' # UK
      string :postCode, api_name: 'postCode' # UK

      validates_inclusion_of :type, :in => ADDRESS_TYPE.keys

    end

  end
end
