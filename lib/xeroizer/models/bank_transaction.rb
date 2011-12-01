module Xeroizer
  module Record
    class BankTransactionModel < BaseModel
      set_permissions :read
    end

    class BankTransaction < Base
      string :type
    end
  end
end

