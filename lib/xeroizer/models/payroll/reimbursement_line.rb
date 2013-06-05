module Xeroizer
  module Record
    module Payroll
    
      class ReimbursementLineModel < PayrollBaseModel
          
      end
      
      # child of PayTemplate
      class ReimbursementLine < PayrollBase

        guid          :reimbursement_type_id
        
        string        :description
        decimal       :amount

      end

    end 
  end
end
