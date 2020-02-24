module Xeroizer
  module Record
    module Payroll
    
      class LeaveAccrualLineModel < PayrollBaseModel
          
      end
      
      # http://developer.xero.com/documentation/payroll-api/payslip/#LeaveAccrualLine
      class LeaveAccrualLine < PayrollBase
        decimal       :number_of_units

        boolean       :auto_calculate

        guid          :leave_type_id

      end

    end 
  end
end
