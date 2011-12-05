require "test_helper"
require "acceptance_test"

class AboutCreatingBankTransactions < Test::Unit::TestCase
  include AcceptanceTest

  can "create new bank transactions" do
    client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)

    account = client.Account.all.select{|account| account.status == "ACTIVE" && account.type == "REVENUE"}.first
    bank_account = client.Account.all.select{|account| account.status == "ACTIVE" && account.type == "BANK"}.first

    new_transaction = client.BankTransaction.build(
      :type => "SPEND",
      :contact => { :name => "Jazz Kang" },
      :line_items => [
        :item_code => "Clingfilm bike shorts",
        :description => "Bike shorts made of clear, unbreathable material",
        :quantity => 1,
        :unit_amount => 39.99,
        :account_code => account.code,
        :tax_type => account.tax_type
      ],
      :bank_account => { :code => bank_account.code }
    )

    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"
  end

  it "fails with RuntimeError when you try and create a new bank account" do
    client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)

    new_account = client.Account.build(
      :name => "Example bank account",
      :code => "ACC-001"
    )

    assert_raise RuntimeError do
      new_account.save
    end
  end

  must "supply either SPEND or RECEIVE as the type"
  must "supply supply a contact"
  must "supply one or more line items"
  must "supply a bank account"
end
