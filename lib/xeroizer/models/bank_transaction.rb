module Xeroizer
  module Record
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
    end
  end
end

