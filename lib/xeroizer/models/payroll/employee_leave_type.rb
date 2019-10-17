module Xeroizer
  module Record
    module Payroll

      class EmployeeLeaveTypeModel < PayrollBaseModel
        set_permissions :read, :write, :update

        def api_url(options)
          if options.keys.include?(:employee_id)
            "employees/#{options.delete(:employee_id)}/leaveTypes"
          end
        end

        def model_name_to_parse
          # HACK so we can use LeaveType to be the iterable
          "LeaveType"
        end
      end

      class EmployeeLeaveType < PayrollBase
        guid          :leave_type_id
        guid          :employee_id

        string        :schedule_of_accrual
        decimal       :hours_accrued_annually
        decimal       :maximum_to_accrue
        decimal       :opening_balance
        decimal       :rate_accrued_hourly

        validates_presence_of :leave_type_id, :schedule_of_accrual

        def api_url
          "employees/#{employee_id}/leaveTypes"
        end
      end

    end
  end
end
