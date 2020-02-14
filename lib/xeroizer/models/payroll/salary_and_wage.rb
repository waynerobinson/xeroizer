module Xeroizer
  module Record
    module Payroll

      class SalaryAndWageModel < PayrollBaseModel

      end

      class SalaryAndWage < PayrollBase

        SALARY_AND_WAGE_TYPE = {
          'HOURLY' => '',
          'SALARY' => ''
        } unless defined?(SALARY_AND_WAGE_TYPE)

        guid          :salary_and_wages_id
        guid          :earnings_type_id
        string        :salary_wages_type
        decimal       :hourly_rate
        decimal       :annual_salary
        decimal       :standard_hours_per_week
        datetime      :effective_date

        validates_presence_of :salary_and_wage_id, :unless => :new_record?
        validates_inclusion_of :salary_wages_type, :in => SALARY_AND_WAGE_TYPE
      end
    end
  end
end