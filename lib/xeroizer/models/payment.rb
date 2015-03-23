module Xeroizer
  module Record

    class PaymentModel < BaseModel

      set_xml_root_name 'Payments'
      set_permissions :read, :write

    end

    class Payment < Base

      set_primary_key :payment_id

      guid          :payment_id
      date          :date
      decimal       :amount
      decimal       :currency_rate
      string        :payment_type
      string        :status
      string        :reference
      datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      boolean       :is_reconciled

      belongs_to    :account
      belongs_to    :invoice
      belongs_to    :credit_note

      def invoice_id
        invoice.id if invoice
      end

      def credit_note_id
        credit_note.id if credit_note
      end

      def account_id
        account.id if account
      end

      def account_code
        account.code if account
      end

    end

  end
end
