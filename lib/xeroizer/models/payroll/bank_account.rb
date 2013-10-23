module Xeroizer
  module Record
    module Payroll
    
      class BankAccountModel < PayrollBaseModel
          
      end
      
      class BankAccount < PayrollBase
        
        string      :statement_text
        string      :account_name
        string      :bsb, :api_name => 'BSB'
        string      :account_number
        boolean     :remainder
        string      :percentage
        decimal     :amount

        validates_length_of :statement_text, length: { maximum: 18 }, :allow_blanks => true
        validates_length_of :account_name, length: { maximum: 32 }, :allow_blanks => true
        validates_length_of :bsb, length: { is: 6 }, :allow_blanks => true
        validates_length_of :account_number, length: { maximum: 9 }, :allow_blanks => true
      end

    end 
  end
end
