module Xeroizer
  module Record
    module Payroll

      class BenefitTypeModel < PayrollBaseModel

        set_permissions :read

      end

      class BenefitType < PayrollBase

        BENEFIT_CATEGORIES = {
          'AFTERTAXBENEFIT' => '',
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
        } unless defined?(BENEFIT_CATEGORIES)

        set_primary_key :benefit_type_id

        guid    :benefit_type_id
        string  :benefit_type
        string  :benefit_category
        string  :liability_account_code
        string  :expense_account_code
        decimal :standard_amount
        decimal :company_max
        decimal :percentage
        boolean :show_balance_on_paystub

        validates_inclusion_of :benefit_category, :in => BENEFIT_CATEGORIES

      end
    end
  end
end