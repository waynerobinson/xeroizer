require "test_helper"
require "acceptance_test"
require "bank_transaction_reference_data"

class AboutFetchingBankTransactions < Test::Unit::TestCase
  include AcceptanceTest

  it_works_using_oauth1_and_oauth2 do |client, client_type|
    context "when requesting a single bank transaction with a reference using #{client_type}" do
      setup do
        @a_new_bank_transaction = BankTransactionReferenceData.new(client).bank_transaction
      end

      it "has the extended set of attributes using #{client_type}" do
        keys = [:line_amount_types, :contact, :date, :status, :line_items,
                :updated_date_utc, :currency_code, :bank_transaction_id,
                :bank_account, :type, :reference, :is_reconciled, :currency_rate]
        assert_equal(keys, @a_new_bank_transaction.attributes.keys)
      end

      it "returns full line item details using #{client_type}" do
        single_bank_transaction = client.BankTransaction.find @a_new_bank_transaction.id

        assert_not_empty single_bank_transaction.line_items,
                         "expected the bank transaction's line items to have been included"
      end
    end

    context "when requesting all bank transactions (i.e., without filter) using #{client_type}" do
      setup do
        @the_first_bank_transaction = client.BankTransaction.all.detect { |trans| trans.attributes.keys.include?(:reference) }
      end

      it "has the limited set of attributes using #{client_type}" do
        keys = [:line_amount_types, :contact, :date, :status, :updated_date_utc,
                :currency_code, :bank_transaction_id, :bank_account, :type, :reference,
                :is_reconciled]
        assert_equal(keys, @the_first_bank_transaction.attributes.keys)
      end

      it "returns contact using #{client_type}" do
        assert_not_nil @the_first_bank_transaction.contact
      end

      it "returns the bank account using #{client_type}" do
        assert_not_nil @the_first_bank_transaction.bank_account
      end
    end
  end
end
