module Xeroizer
  module Record
    module Payroll
    
      class PayRunModel < PayrollBaseModel
          
        set_permissions :read, :write, :update
          
      end
      
      # http://developer.xero.com/documentation/payroll-api/payruns/
      class PayRun < PayrollBase
        
        set_primary_key :pay_run_id

        guid          :pay_run_id

        guid          :payroll_calendar_id

        date          :pay_run_period_end_date
        date          :pay_run_period_start_date
        date          :payment_date

        decimal       :wages
        decimal       :deductions
        decimal       :tax
        decimal       :super
        decimal       :reimbursement
        decimal       :net_pay

        string        :pay_run_status
        string        :payslip_message

        has_many      :payslips

      end

    end 
  end
end
