module Xeroizer
  module Record
    module Payroll

      class BenefitLineModel < PayrollBaseModel

      end

      class BenefitLine < PayrollBase

        BENEFIT_TYPE_CALCULATION_TYPE = {
          'FIXEDAMOUNT' => '',
          'STANDARDAMOUNT' => ''
        } unless defined?(BENEFIT_TYPE_CALCULATION_TYPE)

        guid :benefit_type_id, :api_name => 'BenefitTypeID'
        string :calculation_type
        decimal :amount

        validates_presence_of :benefit_type_id, :calculation_type, :unless => :new_record?
        validates_inclusion_of :calculation_type, :in => BENEFIT_TYPE_CALCULATION_TYPE
      end

    end
  end
end