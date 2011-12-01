module Xeroizer
  module Record
    class BankTransactionModel < BaseModel
      set_permissions :read
    end

    class BankTransaction < Base
      string :type
      date :date
    end
  end
end

