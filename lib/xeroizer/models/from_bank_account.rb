module Xeroizer
  module Record

    class FromBankAccountModel < BaseModel
      set_permissions :read, :write, :update
    end

    class FromBankAccount < Base
      guid   :account_id, :api_name => "AccountID"
      string :code
      string :name
    end
  end
end