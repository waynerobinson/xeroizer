module Xeroizer
  module Record
    module Payroll

      class EarningTemplateModel < PayrollBaseModel

        set_permissions :read, :write, :update


        def api_url(options = {})
          json? ? "employees/#{options.delete(:employee_id)}/paytemplates/earnings/#{options.delete(:pay_template_earning_id)}" : super
        end

        def update
          params = extra_params_for_create_or_update
          params[:url] = api_url
          response = parent.send(:http_put, {}, params)
          parse_save_response(response)
        end

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
        "employees/#{employee_id}/leave/paytemplates/earnings/#{pay_template_earning_id}"
      end

      def update
        params = extra_params_for_create_or_update
        params[:url] = api_url
        response = parent.send(:http_put, {}, params)
        parse_save_response(response)
      end

    end
  end
end
