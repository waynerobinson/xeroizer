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
        decimal       :fixed_amount # UK
        decimal       :multiple_of_ordinary_earnings_rate # UK
        string        :expense_account_id # UK
        boolean       :current_record # UK
        boolean       :is_reportable_as_w1
        string        :employment_termination_payment_type

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        validates_presence_of :name, :type_of_units, :earnings_type # UK has lesser validation requirements

      end

    end
  end
end
