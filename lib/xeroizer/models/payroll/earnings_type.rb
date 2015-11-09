module Xeroizer
  module Record
    module Payroll

      class EarningsTypeModel < PayrollBaseModel

        set_permissions :read

      end

      class EarningsType < PayrollBase

        EARNINGS_CATEGORIES = {
          'REGULAREARNINGS' => '',
          'OVERTIMEEARNINGS' => '',
          'ALLOWANCE' => '',
          'COMMISSION' => '',
          'BONUS' => '',
          'CASHTIPS' => '',
          'NONCASHTIPS' => '',
          'ADDITIONALEARNINGS' => '',
          'RETROACTIVEPAY' => '',
          'CLERGYHOUSINGALLOWANCE' => '',
          'CLERGYHOUSINGINKIND' => ''
        } unless defined?(EARNINGS_CATEGORIES)

        RATE_TYPES = {
          'FIXEDAMOUNT' => '',
          'MULTIPLE' => '',
          'RATEPERUNIT' => ''
        } unless defined?(RATE_TYPES)

        set_primary_key :earnings_type_id

        guid    :earnings_type_id
        guid    :earnings_rate_id
        string  :earnings_type
        string  :expense_account_code
        string  :earnings_category
        string  :rate_type
        string  :type_of_units
        decimal :multiple
        boolean :do_not_accrue_time_off
        boolean :is_supplemental
        decimal :amount

        validates_inclusion_of :earnings_category, :in => EARNINGS_CATEGORIES
        validates_inclusion_of :rate_type, :in => RATE_TYPES

      end
    end
  end
end