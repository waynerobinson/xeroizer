module Xeroizer
  module Record
    module Payroll

      class PeriodModel < PayrollBaseModel
        set_permissions :read

        def api_url(options)
          "employees/#{options.delete(:employee_id)}/leavePeriods?startDate=#{options[:start_date]}&endDate=#{options[:end_date]}"
        end
      end

      class Period < PayrollBase

        decimal     :number_of_units
        date        :period_start_date
        date        :period_end_date
        string      :period_status

        def to_api_json
          JSON.parse(super)
        end
      end

    end
  end
end
