module Xeroizer
  module Record
    module Payroll

      class LeaveTypeModel < PayrollBaseModel
        set_permissions :read, :write, :update

        def api_url(options)
          if options.keys.include?(:employee_id)
            "employees/#{options.delete(:employee_id)}/leaveTypes"
          end
        end
      end

      class LeaveType < PayrollBase

        string        :name
        string        :type_of_units
        boolean       :is_paid_leave
        boolean       :show_on_payslip

        guid          :leave_type_id
        decimal       :normal_entitlement
        decimal       :leave_loading_rate

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        validates_presence_of :name, :type_of_units, :is_paid_leave, :show_on_payslip

      end

    end
  end
end
