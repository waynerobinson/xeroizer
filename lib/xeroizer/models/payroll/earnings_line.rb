module Xeroizer
  module Record
    module Payroll
    
      class EarningsLineModel < PayrollBaseModel
          
      end
      
      class EarningsLine < PayrollBase
        
        EARNINGS_RATE_CALCULATION_TYPE = {
          'USEEARNINGSRATE' => 'Use the rate per unit recorded for the earnings rate under Settings',
          'ENTEREARNINGSRATE' => 'The rate per unit is be added manually to the earnings line',
          'ANNUALSALARY' => 'If the employee receives a salary, the annual salary amount and units of work per week are added to the earnings line'          
        } unless defined?(EARNINGS_RATE_CALCULATION_TYPE)
        EARNINGS_RATE_CALCULATION_TYPES = EARNINGS_RATE_CALCULATION_TYPE.keys.sort
        
        guid          :earnings_rate_id, :api_name => 'EarningsRateID'
        string        :calculation_type

        decimal       :number_of_units_per_week
        decimal       :annual_salary
        decimal       :rate_per_unit
        decimal       :normal_number_of_units
        
        validates_presence_of :earnings_rate_id
        validates_presence_of :calculation_type
        validates_inclusion_of :calculation_type, :in => EARNINGS_RATE_CALCULATION_TYPES
      end

    end 
  end
end
