require 'xeroizer/models/line_item'
require 'xeroizer/models/line_item_sum'

module Xeroizer
  module Record
    class BankTransactionModel < BaseModel
      set_permissions :read
    end

    class BankTransaction < Base
      def initialize(parent)
        super parent
        self.line_amount_types = "Exclusive"
      end

      set_primary_key :bank_transaction_id
      string :type
      date :date

      datetime_utc :updated_date_utc, :api_name => "UpdatedDateUTC"
      date :fully_paid_on_date
      string :reference
      string :bank_transaction_id, :api_name => "BankTransactionID"
      boolean :is_reconciled

      alias_method :reconciled?, :is_reconciled

      belongs_to :contact, :model_name => 'Contact'
      string :line_amount_types
      has_many :line_items, :model_name => 'LineItem'
      belongs_to :bank_account, :model_name => 'BankAccount'

      validates_inclusion_of :line_amount_types,
        :in => Xeroizer::Record::LINE_AMOUNT_TYPES, :allow_blanks => false

      validates_inclusion_of :type,
        :in => %w{SPEND RECEIVE}, :allow_blanks => false,
        :message => "Invalid type. Expected either SPEND or RECEIVE."

      validates_presence_of :contact, :bank_account, :allow_blanks => false

      validates :line_items, :message => "Invalid line items. Must supply at least one." do
        self.line_items.size > 0
      end

      def sub_total=(value); raise SettingTotalDirectlyNotSupported.new(:sub_total); end
      def total_tax=(value); raise SettingTotalDirectlyNotSupported.new(:total_tax); end
      def total=(value);     raise SettingTotalDirectlyNotSupported.new(:total);     end

      def total; sub_total + total_tax; end

      def sub_total
        if ought_to_recalculate_totals?
          result = LineItemSum.sub_total(self.line_items)
          result -= total_tax if line_amount_types == 'Inclusive'
          result
        else
          attributes[:sub_total]
        end
      end

      def total_tax
        return ought_to_recalculate_totals? ?
          LineItemSum.total_tax(self.line_items) :
          attributes[:total_tax]
      end

      private

      def ought_to_recalculate_totals?
        new_record? || line_items && line_items.size > 0
      end
    end
  end
end
