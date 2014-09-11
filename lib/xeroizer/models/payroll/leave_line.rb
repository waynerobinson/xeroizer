module Xeroizer
  module Record
    module Payroll
    
      class LeaveLineModel < PayrollBaseModel
          
      end
      
      # child of PayTemplate
      class LeaveLine < PayrollBase

        guid          :leave_type_id
        string        :calculation_type # http://developer.xero.com/payroll-api/types-and-codes#LeaveTypeCalculationType

        decimal       :annual_number_of_units
        decimal       :full_time_number_of_units_per_period
        decimal       :number_of_units

      end
    end 
  end
end
