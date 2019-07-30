module Xeroizer
  module Record
    module Payroll

      class SalaryAndWagesModel < PayrollBaseModel

        set_permissions :read, :write, :update

        def api_url(options = {})
          "employees/#{options.delete(:employee_id)}/salaryAndWages"
        end
      end

      class SalaryAndWages < PayrollBase

        guid          :salary_and_wages_id
        guid          :earnings_rate_id

        decimal       :number_of_units_per_week
        decimal       :rate_per_unit
        decimal       :number_of_units_per_day
        decimal       :annual_salary

        datetime_utc  :effective_from

        string        :status
        string        :payment_type
      end

    end
  end
end
