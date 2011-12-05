require "test_helper"
require "acceptance_test"

class AboutFetchingBankTransactions < Test::Unit::TestCase
  include AcceptanceTest

  context "when requesting all bank transactions (i.e., without filter)" do
    setup do 
      client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
      @the_bank_transactions = client.BankTransaction.all
      @the_first_bank_transaction = @the_bank_transactions.first
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
    it "returns expanded contacts and addresses"
    it "returns full line item details"
  end
end
