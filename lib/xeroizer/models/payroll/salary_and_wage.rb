module Xeroizer
  module Record
    module Payroll

      class SalaryAndWageModel < PayrollBaseModel

      end

      class SalaryAndWage < PayrollBase

        SALARY_AND_WAGE_TYPE = {
          'FIXEDAMOUNTEACHPERIOD' => 'You can enter a manually calculated rate for the accrual, accrue a fixed amount of leave each pay period based on an annual entitlement (for example, if you pay your employees monthly, you would accrue 1/12th of their annual entitlement each month), or accrue an amount relative to the number of hours an employee worked in the pay period',
          'ENTERRATEINPAYTEMPLATE' => '',
          'BASEDONORDINARYEARNINGS' => ''
        } unless defined?(SALARY_AND_WAGE_TYPE)

        guid          :salary_and_wage_id
        guid          :earnings_type_id
        string        :salary_wages_type
        decimal       :hourly_rate
        decimal       :annual_salary
        decimal       :standard_hours_per_week
        datetime_utc  :effective_date

        validates_presence_of :salary_and_wage_id, :unless => :new_record?
        validates_inclusion_of :salary_wages_type, :in => SALARY_AND_WAGE_TYPE
      end
    end
  end
end