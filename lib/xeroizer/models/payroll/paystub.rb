module Xeroizer
  module Record
    module Payroll

      class PaystubModel < PayrollBaseModel

        set_permissions :read, :write, :update

      end

      class Paystub < PayrollBase

        set_primary_key :paystub_id

        guid          :paystub_id
        guid          :employee_id
        guid          :pay_run_id
        string        :first_name
        string        :last_name
        datetime      :last_edited
        decimal       :earnings
        decimal       :deductions
        decimal       :tax
        decimal       :reimbursements
        decimal       :net_pay
        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
        date          :payment_date

        has_many      :earnings_lines
        has_many      :leave_earnings_lines, :model_name => 'EarningsLine'
        has_many      :timesheet_earnings_lines, :model_name => 'EarningsLine'
        has_many      :deduction_lines
        has_many      :reimbursement_lines
        has_many      :benefit_lines
        has_many      :time_off_lines

        belongs_to    :pay_run

        validates_presence_of :paystub_id, :unless => :new_record?

      end
    end
  end
end
