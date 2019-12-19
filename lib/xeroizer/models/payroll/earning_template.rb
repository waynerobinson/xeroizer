module Xeroizer
  module Record
    module Payroll

      class EarningTemplateModel < PayrollBaseModel

        set_permissions :read, :write, :update

      end
      # https://developer.xero.com/documentation/payroll-api-uk/employeepaytemplates
      class EarningTemplate < PayrollBase

        guid          :pay_template_earning_id
        guid          :earnings_rate_id

        string        :name

        decimal       :rate_per_unit
        decimal       :number_of_units
        decimal       :fixed_amount

      end

      def api_url
        json? ? "employees/#{employee_id}/paytemplates/earnings/#{pay_template_earning_id}" : super
      end

    end
  end
end
