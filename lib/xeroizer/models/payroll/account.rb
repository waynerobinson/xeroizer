module Xeroizer
  module Record
    module Payroll
    
      class AccountModel < PayrollBaseModel

        set_permissions :read
          
      end
      
      class Account < PayrollBase

        string        :type
        string        :code
        string        :name
        guid          :account_id
      end

    end 
  end
end
