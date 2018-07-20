module Xeroizer
  module Record
    module Payroll

      class LeaveModel < PayrollBaseModel

        set_permissions :read, :write, :update

        def api_url
          "employees/#{options[:employee_id]}/leave"
        end
      end

      class Leave < PayrollBase

        set_primary_key :leave_id

        guid          :employee_id
        guid          :leave_id
        guid          :leave_type_id
        string        :description
        date          :start_date
        date          :end_date
        datetime_utc  :updated_date_utc


        has_many      :periods#, :internal_name_singular => "period", :model_name => "LeavePeriod"

        def api_url
          "employees/#{employee_id}/leave"
        end

      end

    end
  end
end
