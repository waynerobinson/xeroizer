module Xeroizer
  module Record
    module Payroll

      class PayRunModel < PayrollBaseModel

        set_permissions :read, :write, :update

      end

      class PayRun < PayrollBase

        set_primary_key :pay_run_id

        guid :pay_run_id
        guid :pay_schedule_id
        date :pay_run_period_end_date
        string :pay_run_status
        date :pay_run_period_start_date
        date :payment_date
        decimal :earnings
        decimal :deductions
        decimal :reimbursement
        decimal :net_pay
        decimal :tax
        datetime_utc :updated_date_utc, :api_name => 'UpdatedDateUTC'

        has_many :paystubs

      end
    end
  end
end