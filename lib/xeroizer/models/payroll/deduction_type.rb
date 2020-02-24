module Xeroizer
  module Record
    module Payroll

      class DeductionTypeModel < PayrollBaseModel

        set_permissions :read

      end

      class DeductionType < PayrollBase

        DEDUCTION_CATEGORIES = {
          'AFTERTAXDEDUCTION' => '',
          'DEPENDENTCARE' => '',
          'FLEXIBLESPENDINGACCOUNT' => '',
          'HEALTHSAVINGSACCOUNTSINGLEPLAN' => '',
          'HEALTHSAVINGSACCOUNTFAMILYPLAN' => '',
          'ROTH401KREITREMENTPLAN' => '',
          'ROTH403BRETIREMENTPLAN' => '',
          'SECTION125PLAN' => '',
          'SIMPLEIRARETIREMENTPLAN' => '',
          '401KRETIREMENTPLAN' => '',
          '403BRETIREMENTPLAN' => '',
          '457RETIREMENTPLAN' => ''
        } unless defined?(DEDUCTION_CATEGORIES)

        CALCULATION_TYPES = {
          'CATCHUPPLAN' => '',
          'STANDARDPLAN' => ''
        } unless defined?(CALCULATION_TYPES)

        set_primary_key :deduction_type_id

        string        :name
        string        :account_code # http://developer.xero.com/api/Accounts
        boolean       :reduces_super
        boolean       :reduces_tax

        guid          :deduction_type_id

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        string  :deduction_type
        string  :deduction_category
        string  :calculation_type
        string  :liability_account_code
        decimal :standard_amount
        decimal :company_max

        validates_inclusion_of :deduction_category, :in => DEDUCTION_CATEGORIES
        validates_inclusion_of :calculation_type, :in => CALCULATION_TYPES

        validates_presence_of :name, :account_code, :reduces_tax, :reduces_super
      end

    end 
  end
end
