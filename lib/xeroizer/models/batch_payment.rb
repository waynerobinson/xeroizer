module Xeroizer
  module Record

    class BatchPaymentModel < BaseModel
      set_permissions :read, :write
    end

    class BatchPayment < Base
      set_primary_key :batch_payment_id
      list_contains_summary_only false

      guid    :batch_payment_id
      string  :reference
      string  :details
      date    :date
      string  :type
      string  :status
      decimal :total_amount
      boolean :is_reconciled

      datetime_utc :updated_date_utc, :api_name => 'UpdatedDateUTC'

      belongs_to :account
      has_many   :payments
    end
  end
end
