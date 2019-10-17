module Xeroizer
  module Record
    module Payroll

      class PayTemplateModel < PayrollBaseModel

      end

      class PayTemplate < PayrollBase

        has_many      :earnings_lines
        has_many      :deduction_lines
        has_many      :super_lines
        has_many      :reimbursement_lines
        has_many      :leave_lines

        # US Payroll fields
        has_many      :benefit_lines

      end

    end
  end
end