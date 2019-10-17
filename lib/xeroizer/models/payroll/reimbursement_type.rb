module Xeroizer
  module Record
    module Payroll

      class ReimbursementTypeModel < PayrollBaseModel

        set_permissions :read

      end

      class ReimbursementType < PayrollBase

        set_primary_key :reimbursement_type_id

        string        :name
        string        :account_code # http://developer.xero.com/api/Accounts

        guid    :reimbursement_type_id
        string  :reimbursement_type
        string  :expense_or_liability_account_code

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        validates_presence_of :name, :account_code
      end
    end
  end
end