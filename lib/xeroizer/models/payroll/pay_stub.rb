module Xeroizer
  module Record
    module Payroll

      class PaystubModel < PayrollBaseModel
        set_permissions :read, :write, :update
      end

      class Paystub < PayrollBase
        set_primary_key :paystub_id

        guid :paystub_id
        guid :employee_id
        string :first_name
        string :last_name
        datetime_utc :last_edited
        decimal :earnings
        decimal :deductions
        decimal :tax
        decimal :reimbursements
        decimal :net_pay
        datetime_utc :updated_date_utc, :api_name => 'UpdatedDateUTC'

        belongs_to :pay_run
      end
    end
  end
end
