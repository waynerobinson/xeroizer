require 'xeroizer/models/line_item'

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
      def initialize(parent)
        super parent
        self.line_amount_type = "Exclusive"
      end

      set_primary_key :bank_transaction_id
      string :type
      date :date
      string :line_amount_types
      decimal :total_tax
      decimal :sub_total
      decimal :total

      date :updated_date_utc, :api_name => "UpdatedDateUTC"
      date :fully_paid_on_date
      string :bank_transaction_id, :api_name => "BankTransactionID"
      boolean :is_reconciled

      alias_method :reconciled?, :is_reconciled

      belongs_to :contact, :model_name => 'Contact'
      string :line_amount_type
      has_many :line_items, :model_name => 'LineItem'
      belongs_to :bank_account, :model_name => 'BankAccount'

      validates_inclusion_of :line_amount_type,
        :in => Xeroizer::Record::LineItem::LINE_AMOUNT_TYPES, :allow_blanks => false

      validates_inclusion_of :type, :in => %w{SPEND RECEIVE}, :allow_blanks => false, 
        :message => "Invalid type. Expected either SPEND or RECEIVE."
      
      validates_presence_of :contact, :bank_account, :allow_blanks => false
      
      validates :line_items, :message => "Invalid line items. Must supply at least one." do
        self.line_items.size > 0
      end

      private

      def total_core
        self.line_items.map do |line_item|
          BigDecimal(line_item[:line_amount].to_s) + BigDecimal(line_item[:tax_amount].to_s)
        end.reduce :+
      end
    end
  end
end
