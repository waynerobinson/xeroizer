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

      validates_inclusion_of :type, :in => ADDRESS_TYPE.keys
      validates_length_of :address_line1, :max => 500
      validates_length_of :address_line2, :max => 500
      validates_length_of :address_line3, :max => 500
      validates_length_of :address_line4, :max => 500
      validates_length_of :city, :max => 255
      validates_length_of :region, :max => 255
      validates_length_of :postal_code, :max => 50
      validates_length_of :country, :max => 50
      validates_length_of :attention_to, :max => 255

    end

  end
end
