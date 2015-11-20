module Xeroizer
  module Record
    module Payroll

      class AddressModel < PayrollBaseModel
      end

      class Address < PayrollBase

        string      :address_line1
        string      :address_line2
        string      :city
        string      :region
        string      :postal_code
        string      :country

        # US Payroll fields
        string      :street_address
        string      :suite_or_apt_or_unit
        string      :state
        string      :zip
        decimal     :latitude
        decimal     :longitude

      end

      class HomeAddressModel < AddressModel
        set_xml_node_name 'HomeAddress'
      end

      class HomeAddress < Address
      end

      class MailingAddressModel < AddressModel
        set_xml_node_name 'MailingAddress'
      end

      class MailingAddress < Address
      end

    end
  end
end
