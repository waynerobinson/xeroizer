module Xeroizer
  module Record
    module Payroll

      class AddressModel < PayrollBaseModel

      end

      class Address < PayrollBase
        # UK
        string      :addressLine1
        string      :addressLine2
        string      :addressLine3
        string      :city
        string      :country
        string      :postCode
      end

      def to_api_json
        JSON.parse(super)
      end

    end
  end
end
