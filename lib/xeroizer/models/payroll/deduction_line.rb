module Xeroizer
  module Record
    module Payroll

      class DeductionLineModel < PayrollBaseModel

      end

      class DeductionLine < PayrollBase

        DEDUCTION_TYPE_CALCULATION_TYPE = {
          'FIXEDAMOUNT' => '',
          'PRETAX' => '',
          'POSTTAX' => ''
        } unless defined?(DEDUCTION_TYPE_CALCULATION_TYPE)

        guid          :deduction_type_id, :api_name => 'DeductionTypeID'
        string        :calculation_type

        decimal :percentage
        decimal :amount

        # US Payroll fields
        decimal :employee_max

        validates_presence_of :earning_rate_id, :calculation_type, :unless => :new_record?
        validates_inclusion_of :calculation_type, :in => DEDUCTION_TYPE_CALCULATION_TYPE
      end

    end
  end
end