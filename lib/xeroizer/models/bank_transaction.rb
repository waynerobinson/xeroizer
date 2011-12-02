
module Xeroizer
  module Record
    class BankAccountModel < BaseModel
      set_permissions :read
    end

    class BankAccount < Base
      string :account_id
    end

    class BankTransactionModel < BaseModel
      set_permissions :read
    end

    class BankTransaction < Base
      string :type
      date :date
      string :line_amount_types
      decimal :sub_total
      decimal :total_tax
      date :updated_date_utc
      date :fully_paid_on_date
      string :bank_transaction_id
      boolean :is_reconciled

      alias_method :reconciled?, :is_reconciled

      belongs_to :contact, :model_name => 'Contact'
      has_many :line_items, :model_name => 'LineItem'
      belongs_to :bank_account, :model_name => 'BankAccount'
    end
  end
end
