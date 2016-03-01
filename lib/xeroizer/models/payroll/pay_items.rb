module Xeroizer
  module Record
    module Payroll

      class PayItemsModel < PayrollBaseModel

        set_permissions :read

      end

      class PayItems < PayrollBase

        has_many      :earnings_types
        has_many      :benefit_types
        has_many      :deduction_types
        has_many      :reimbursement_types
        has_many      :time_off_types

      end
    end
  end
end
