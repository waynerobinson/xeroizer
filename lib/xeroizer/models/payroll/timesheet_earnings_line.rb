module Xeroizer
  module Record
    module Payroll
    
      class TimesheetEarningsLineModel < PayrollBaseModel
          
      end
      
      # child of Payslip
      class TimesheetEarningsLine < PayrollBase

        guid          :earnings_rate_id
        decimal       :number_of_units
        decimal       :rate_per_unit

      end

    end 
  end
end
