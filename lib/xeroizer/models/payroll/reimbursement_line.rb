module Xeroizer
  module Record
    module Payroll
    
      class ReimbursementLineModel < PayrollBaseModel
          
      end
      
      class ReimbursementLine < PayrollBase
        
        guid :reimbursement_type_id, :api_name => 'ReimbursementTypeID'

        string :description
        decimal :amount
        
        validates_presence_of :reimbursement_type_id, :unless => :new_record?
      end

    end 
  end
end