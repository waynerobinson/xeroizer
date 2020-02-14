module Xeroizer
  module Record
    module Payroll

      class AddressModel < PayrollBaseModel

        class_inheritable_attributes :api_controller_name
        class_inheritable_attributes :permissions
        class_inheritable_attributes :xml_root_name
        class_inheritable_attributes :optional_xml_root_name
        class_inheritable_attributes :xml_node_name

      end

      class Address < PayrollBase

        class_inheritable_attributes :fields, :possible_primary_keys, :primary_key_name, :summary_only, :validators


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
