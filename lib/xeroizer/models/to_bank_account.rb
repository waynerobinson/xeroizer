module Xeroizer
  module Record

    class ToBankAccountModel < BaseModel
      set_permissions :read, :write, :update
    end

    class ToBankAccount < Base
      guid   :account_id, :api_name => "AccountID"
      string :code
      string :name
    end
  end
end