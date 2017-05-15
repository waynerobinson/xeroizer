module Xeroizer
  module Record
    module Payroll

      class SuperFund < PayrollBaseModel

      end

      class SuperFund < PayrollBase

        guid   :super_fund_id
        string :type
        string :abn, api_name: "ABN"

        # this is for Regulated funds
        string :usi, api_name: "USI"

        # this is for self-managed funds
        string :name
        string :bsb, api_name: "BSB"
        string :account_number
        string :account_name
        string :electronic_service_address
      end

    end
  end
end
