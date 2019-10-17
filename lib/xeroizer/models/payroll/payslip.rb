module Xeroizer
  module Record
    module Payroll
    
      class PayslipModel < PayrollBaseModel
          
        set_api_controller_name 'Payslip'

        set_api_response_padding 'Payslip'
        
        set_permissions :read, :update
          
      end
      
      # http://developer.xero.com/documentation/payroll-api/payslip/
      class Payslip < PayrollBase
        
        set_primary_key :payslip_id

        guid          :payslip_id
        guid          :employee_id
        guid          :pay_run_id

        string        :first_name
        string        :last_name

        decimal       :wages
        decimal       :deductions
        decimal       :net_pay
        decimal       :tax
        decimal       :super
        decimal       :reimubrsements

        has_many      :earnings_lines, model_name: "EarningsLine"
        has_many      :tax_lines, model_name: "TaxLine"
        has_many      :timesheet_earnings_lines, model_name: "TimesheetEarningsLine"
        has_many      :deduction_lines, model_name: "DeductionLine"
        has_many      :leave_accrual_lines, model_name: "LeaveAccrualLine"
        has_many      :superannuation_lines, :internal_name_singular => "super_line", :model_name => "SuperLine"
        has_many      :reimbursement_lines, model_name: "ReimbursementLine"

      end

    end 
  end
end
