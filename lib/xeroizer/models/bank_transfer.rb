require 'xeroizer/models/attachment'

module Xeroizer
  module Record
    class BankTransferModel < BaseModel
      set_permissions :read

      include AttachmentModel::Extensions
    end

    class BankTransfer < Base
      include Attachment::Extensions

      set_primary_key :bank_transfer_id

      decimal :amount

      date :date
      string :bank_transfer_id, :api_name => "BankTransferID"
      decimal :currency_rate
      string :from_bank_transaction_id, :api_name => "FromBankTransactionID"
      string :to_bank_transaction_id, :api_name => "ToBankTransactionID"

      validates_presence_of :from_bank_account, :to_bank_account, :amount

      belongs_to :from_bank_account, :model_name => 'FromBankAccount'
      belongs_to :to_bank_account, :model_name => 'ToBankAccount'
    end
  end
end