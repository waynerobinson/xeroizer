require 'xeroizer/models/line_item'
require 'xeroizer/models/line_item_sum'
require 'xeroizer/models/attachment'

module Xeroizer
  module Record
    class BankTransactionModel < BaseModel
      set_permissions :read

      include AttachmentModel::Extensions
    end

    class BankTransaction < Base

      BANK_TRANSACTION_STATUS = {
        'AUTHORISED'  =>          'Active bank transactions',
        'DELETED' =>          'Deleted bank transactions',
      } unless defined?(BANK_TRANSACTION_STATUS)
      BANK_TRANSACTION_STATUSES = BANK_TRANSACTION_STATUS.keys.sort

      include Attachment::Extensions

      def initialize(parent)
        super parent
        self.line_amount_types = "Exclusive"
      end

      set_primary_key :bank_transaction_id
      list_contains_summary_only true

      string :type
      date :date

      datetime_utc  :updated_date_utc, :api_name => "UpdatedDateUTC"
      date          :fully_paid_on_date
      string        :url
      string        :reference
      string        :bank_transaction_id, :api_name => "BankTransactionID"
      boolean       :is_reconciled
      string        :status
      string        :currency_code
      decimal       :currency_rate

      alias_method :reconciled?, :is_reconciled

      belongs_to :contact, :model_name => 'Contact'
      string :line_amount_types
      has_many :line_items, :model_name => 'LineItem', :complete_on_page => true
      belongs_to :bank_account, :model_name => 'BankAccount'

      validates_inclusion_of :line_amount_types,
        :in => Xeroizer::Record::LINE_AMOUNT_TYPES, :allow_blanks => false

      validates_inclusion_of :type,
        :in => %w{SPEND RECEIVE RECEIVE-PREPAYMENT RECEIVE-OVERPAYMENT}, :allow_blanks => false,
        :message => "Invalid type. Expected either SPEND, RECEIVE, RECEIVE-PREPAYMENT or RECEIVE-OVERPAYMENT."
      validates_inclusion_of :status, :in => BANK_TRANSACTION_STATUSES, :allow_blanks => true

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
