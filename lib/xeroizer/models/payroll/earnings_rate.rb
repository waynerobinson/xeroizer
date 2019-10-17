module Xeroizer
  module Record
    module Payroll

      class EarningsRateModel < PayrollBaseModel

        set_permissions :read, :write, :update

      end

      class EarningsRate < PayrollBase

        string        :name
        string        :account_code # http://developer.xero.com/api/Accounts
        string        :type_of_units
        boolean       :is_exempt_from_tax
        boolean       :is_exempt_from_super
        string        :earnings_type # http://developer.xero.com/payroll-api/types-and-codes/#EarningsTypes

        guid          :earnings_rate_id
        string        :rate_type # http://developer.xero.com/payroll-api/types-and-codes/#EarningsRateTypes
        decimal       :rate_per_unit
        decimal       :multiplier
        boolean       :accrue_leave
        decimal       :amount
        boolean       :is_reportable_as_w1

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        validates_presence_of :name, :account_code, :type_of_units, :is_exempt_from_super, :is_exempt_from_tax, :earnings_type

      end

    end
  end
end
