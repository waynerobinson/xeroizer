module Xeroizer
  module Record
    module Payroll
    
      class EarningsLineModel < PayrollBaseModel
          
      end
      
      # child of PayTemplate, Payslip, OpeningBalance
      class EarningsLine < PayrollBase

        guid          :earnings_rate_id
        string        :calculation_type # http://developer.xero.com/payroll-api/types-and-codes/#EarningsRateCalculationType

        decimal       :number_of_units_per_week
        decimal       :number_of_units
        decimal       :annual_salary
        decimal       :rate_per_unit
        decimal       :normal_number_of_units
        decimal       :amount

      end

    end 
  end
end
