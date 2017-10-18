module Xeroizer
  module Record
    class BankTransferModel < BaseModel
      set_permissions :read, :write, :update
    end

    class BankTransfer < Base

      def initialize(parent)
        super parent
      end

      set_primary_key :bank_transfer_id

      string          :bank_transfer_id, :api_name => "BankTransferID"
      datetime_utc    :created_date_utc, :api_name => "CreatedDateUTC"
      date            :date
      decimal         :amount
      decimal         :currency_rate
      string          :from_bank_transaction_id, :api_name => "FromBankTransactionID"
      string          :to_bank_transaction_id, :api_name => "ToBankTransactionID"

      validates_presence_of :from_bank_account, :to_bank_account, :allow_blanks => false
      belongs_to :from_bank_account, :model_name => 'FromBankAccount'
      belongs_to :to_bank_account, :model_name => 'ToBankAccount'
    end
  end
end
