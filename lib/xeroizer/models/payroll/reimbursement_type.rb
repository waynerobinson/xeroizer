module Xeroizer
  module Record
    module Payroll
    
      class ReimbursementTypeModel < PayrollBaseModel
          
      end
      
      class ReimbursementType < PayrollBase

        string        :name
        string        :account_code # http://developer.xero.com/api/Accounts

        guid          :reimbursement_type_id

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        validates_presence_of :name, :account_code

      end

    end 
  end
end
