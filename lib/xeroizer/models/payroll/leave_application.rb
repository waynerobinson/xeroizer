module Xeroizer
  module Record
    module Payroll
      class LeaveApplicationModel < PayrollBaseModel
        set_permissions :read, :write, :update
      end

      class LeaveApplication < PayrollBase
        set_primary_key :leave_application_id

        guid          :leave_application_id
        guid          :employee_id
        guid          :leave_type_id

        string        :title
        date          :start_date
        date          :end_date

        string        :description

        has_many      :leave_periods

        validates_presence_of :employee_id, :leave_type_id, :title, :start_date, :end_date
      end
    end
  end
end
