module Xeroizer
  module Record
    module Payroll
    
      class DeductionLineModel < PayrollBaseModel
          
      end
      
      # child of PayTemplate
      class DeductionLine < PayrollBase

        guid          :deduction_type_id
        string        :calculation_type # http://developer.xero.com/payroll-api/types-and-codes#DeductionTypeCalculationType

        decimal       :percentage
        decimal       :amount

      end

    end 
  end
end
