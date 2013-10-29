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
        DEDUCTION_TYPE_CALCULATION_TYPES = DEDUCTION_TYPE_CALCULATION_TYPE.keys.sort

        guid          :deduction_type_id, :api_name => 'DeductionTypeID'
        string        :calculation_type

        decimal :percentage
        decimal :amount
        
        validates_presence_of :deduction_type_id
        validates_presence_of :calculation_type
        validates_inclusion_of :calculation_type, :in => DEDUCTION_TYPE_CALCULATION_TYPES
      end

    end 
  end
end