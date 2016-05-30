require "xeroizer/models/accounts_receivable"
require "xeroizer/models/accounts_payable"

module Xeroizer
  module Record
    
    class BalancesModel < BaseModel
      set_permissions :read
    end
    
    class Balances < Base
      has_one :accounts_receivable
      has_one :accounts_payable
    end
  end
end
