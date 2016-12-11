module Xeroizer
  module Record
    module Payroll

      class EarningsTypeModel < PayrollBaseModel

      end

      # https://developer.xero.com/documentation/payroll-api-us/pay-items/#EarningsTypes
      class EarningsType < PayrollBase

        string        :earnings_type
        string        :expense_account_code # http://developer.xero.com/api/Accounts
        string        :earnings_category # https://developer.xero.com/documentation/payroll-api-us/types-codes/#EarningsCategory
        string        :rate_type
        string        :type_of_units
        string        :earnings_type # http://developer.xero.com/payroll-api/types-and-codes/#EarningsTypes

        guid          :earnings_rate_id
        decimal       :multiple
        boolean       :do_not_accrue_time_off
        boolean       :is_supplemental
        decimal       :amount

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        validates_presence_of :earnings_type, :expense_account_code, :earnings_category

      end

    end
  end
end
