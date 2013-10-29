module Xeroizer
  module Record
    module Payroll
    
      class ReimbursementTypeModel < PayrollBaseModel
      end
      
      class ReimbursementType < PayrollBase
        
        set_primary_key :reimbursement_type_id

        guid :reimbursement_type_id, :api_name => 'ReimbursementTypeID'
        string        :name
        string        :account_code
        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
        
        validates_presence_of :reimbursement_type_id, :unless => :new_record?
        validates_presence_of :name
        validates_length_of :name, length: { maximum: 50 }
        validates_presence_of :account_code
      end

    end 
  end
end