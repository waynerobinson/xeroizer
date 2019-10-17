module Xeroizer
  module Record
    module Payroll
    
      class PayslipModel < PayrollBaseModel
          
        set_permissions :read, :update
          
      end
      
      # http://developer.xero.com/documentation/payroll-api/payslip/
      class Payslip < PayrollBase
        
        set_primary_key :payslip_id

        guid          :payslip_id

        guid          :employee_id

        has_many      :earnings_lines
        #has_many      :timesheet_earnings_lines # TODO
        has_many      :deduction_lines
        #has_many      :leave_accrual_lines # TODO
        has_many      :superannuation_lines, :internal_name_singular => "super_line", :model_name => "SuperLine"
        has_many      :reimbursement_lines

      end

    end 
  end
end
