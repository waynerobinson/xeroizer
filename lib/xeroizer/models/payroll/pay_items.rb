module Xeroizer
  module Record
    module Payroll
    
      class PayItemsModel < PayrollBaseModel
        # set_permissions :read, :write, :update
        set_permissions :read
      end

      class PayItems < PayrollBase
        has_many      :earnings_rates
        has_many      :deduction_types
        has_many      :leave_types
        has_many      :reimbursement_types
      end
    end
  end
end