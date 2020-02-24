module Xeroizer
  module Record
    module Payroll

      class LeaveBalanceModel < PayrollBaseModel

        set_permissions :read, :write, :update

        def api_url(options = {})
          "employees/#{options.delete(:employee_id)}/leavebalances"
        end
      end

      # child of Employee
      class LeaveBalance < PayrollBase

        # AU: # https://developer.xero.com/documentation/payroll-api/leavebalances/
        string      :leave_name
        guid        :leave_type_id
        decimal     :number_of_units
        string      :type_of_units

        # UK: https://developer.xero.com/documentation/payroll-api-uk/employeeleavebalances
        # NZ: https://developer.xero.com/documentation/payroll-api-nz/leavebalances
        string      :name
        decimal     :balance

      end

    end
  end
end
