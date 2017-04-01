module Xeroizer
  module Record
    module Payroll

      class AddressModel < PayrollBaseModel
      end

      class Address < PayrollBase

        string      :address_line1
        string      :address_line2
        string      :address_line3
        string      :address_line4
        string      :city
        string      :region
        string      :postal_code
        string      :country

        # US Payroll fields
        string      :street_address
        string      :suite_or_apt_or_unit
        string      :state
        string      :zip
        decimal      :latitude
        decimal      :longitude

      end

    end
  end
end
