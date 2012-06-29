require "test_helper"
require "acceptance_test"
require "bank_transaction_reference_data"

class AboutFetchingBankTransactions < Test::Unit::TestCase
  include AcceptanceTest

  def client
    @client ||= Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
  end

  context "when requesting all bank transactions (i.e., without filter)" do
    setup do
      @the_first_bank_transaction = client.BankTransaction.all.first
    end

    it "returns line items empty" do
      assert_empty(@the_first_bank_transaction.line_items, "Expected line items to've been excluded")
    end

    it "returns contact with name and and id ONLY (no addresses or phones)" do
      the_contact = @the_first_bank_transaction.contact
      assert_not_nil(the_contact.contact_id, "Expected contact id to be present")
      assert_not_nil(the_contact.name, "Expected contact name to be present")
      assert_empty the_contact.phones, "Expected empty contact phones"
      assert_empty the_contact.addresses, "Expected empty contact addresses"
    end

    it "returns the bank account" do
      assert_not_nil @the_first_bank_transaction.bank_account
    end
  end

  context "when requesting a single bank transaction for example" do
    setup do
      @a_new_bank_transaction = BankTransactionReferenceData.new(client).bank_transaction
    end

    it "returns contact with addresses and phones" do
      single_bank_transaction = client.BankTransaction.find @a_new_bank_transaction.id

      assert_not_empty single_bank_transaction.contact.addresses,
        "expected the contact's addresses to have been included"

      assert_not_empty single_bank_transaction.contact.phones,
        "expected the contact's phone numbers to have been included"
    end

    it "returns full line item details" do
      single_bank_transaction = client.BankTransaction.find @a_new_bank_transaction.id

      assert_not_empty single_bank_transaction.line_items,
        "expected the bank transaction's line items to have been included"
    end
  end
end
