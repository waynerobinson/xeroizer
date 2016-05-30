module Xeroizer
  module Record
    
    class AccountsPayableModel < BaseModel
      set_permissions :read
    end
    
    class AccountsPayable < Base
      decimal :outstanding
      decimal :overdue
    end
  end
end
