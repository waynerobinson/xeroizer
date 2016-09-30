module Xeroizer
  module Record
    
    class AccountsReceivableModel < BaseModel
      set_permissions :read
    end
    
    class AccountsReceivable < Base
      decimal :outstanding
      decimal :overdue
    end
  end
end
