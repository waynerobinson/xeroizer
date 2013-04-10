module Xeroizer
  module Record
    module Payroll
    
      class BankAccountModel < PayrollBaseModel
          
      end
      
      class BankAccount < PayrollBase
        
        string      :statement_text
        string      :account_name
        string      :bsb
        string      :account_number
        boolean     :remainder
        string      :percentage
        decimal     :amount

      end

    end 
  end
end
