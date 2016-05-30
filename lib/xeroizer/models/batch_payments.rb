module Xeroizer
  module Record
    
    class BatchPaymentsModel < BaseModel
      set_permissions :read
    end
    
    class BatchPayments < Base
      guid   :bank_account_number
      string :bank_account_name
      string :details
    end
  end
end
