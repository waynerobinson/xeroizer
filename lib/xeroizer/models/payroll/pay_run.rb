module Xeroizer
  module Record
    module Payroll

      class PayRunModel < PayrollBaseModel
        set_permissions :read
      end

      class PayRun < PayrollBase

        set_primary_key :pay_run_id
        guid            :pay_run_id
        datetime        :payment_date
        guid            :payroll_calendar_id
        datetime        :pay_run_period_start_date
        datetime        :pay_run_period_end_date
        datetime        :payment_date
        decimal         :wages
        decimal         :deductions
        decimal         :tax
        decimal         :super
        decimal         :reimbursement
        decimal         :net_pay
        string          :pay_run_status
        datetime        :updated_date_utc
      end

    end
  end
end
