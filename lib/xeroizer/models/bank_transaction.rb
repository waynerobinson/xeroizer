
module Xeroizer
  module Record
    class BankAccountModel < BaseModel
      set_permissions :read
    end

    class BankAccount < Base
      string :account_id
      string :code
    end

    class BankTransactionModel < BaseModel
      set_permissions :read
    end

    class BankTransaction < Base
      set_primary_key :bank_transaction_id
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

      validates_inclusion_of :type, :in => %w{SPEND RECEIVE}, :allow_blanks => false, 
        :message => "Invalid type, Expected either SPEND or RECEIVE."
    end
  end
end
