module Xeroizer
  module Record
    module Payroll

      class ReimbursementTypeModel < PayrollBaseModel

        set_permissions :read

      end

      class ReimbursementType < PayrollBase

        set_primary_key :reimbursement_type_id

        guid    :reimbursement_type_id
        string  :reimbursement_type
        string  :expense_or_liability_account_code

      end
    end
  end
end