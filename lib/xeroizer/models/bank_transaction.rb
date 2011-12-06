
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

      def total
        self.line_items.map do |line_item|
          item_total = line_item[:unit_amount].to_f + line_item[:tax_amount].to_f
          (item_total * line_item[:quantity].to_f).to_f
        end.reduce :+
      end

      date :updated_date_utc, :api_name => "UpdatedDateUTC"
      date :fully_paid_on_date
      string :bank_transaction_id, :api_name => "BankTransactionID"
      boolean :is_reconciled

      alias_method :reconciled?, :is_reconciled

      belongs_to :contact, :model_name => 'Contact'
      has_many :line_items, :model_name => 'LineItem'
      belongs_to :bank_account, :model_name => 'BankAccount'

      validates_inclusion_of :type, :in => %w{SPEND RECEIVE}, :allow_blanks => false, 
        :message => "Invalid type. Expected either SPEND or RECEIVE."
      
      validates_presence_of :contact, :bank_account, :allow_blanks => false
      
      validates :line_items, :message => "Invalid line items. Must supply at least one." do
        self.line_items.size > 0
      end
    end
  end
end
