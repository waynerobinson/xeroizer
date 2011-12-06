require "test_helper"
require "acceptance_test"

class AboutCreatingBankTransactions < Test::Unit::TestCase
  include AcceptanceTest

  def client
    @client ||=  Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
  end

  can "create new bank transactions" do
    all_accounts = client.Account.all

    account = all_accounts.select{|account| account.status == "ACTIVE" && account.type == "REVENUE"}.first
    bank_account = all_accounts.select{|account| account.status == "ACTIVE" && account.type == "BANK"}.first

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
    new_account = client.Account.build(
      :name => "Example bank account",
      :code => "ACC-001"
    )

    assert_raise RuntimeError do
      new_account.save
    end
  end

  must "supply either SPEND or RECEIVE as the type" do
    all_accounts = client.Account.all

    account = all_accounts.select{|account| account.status == "ACTIVE" && account.type == "REVENUE"}.first
    bank_account = all_accounts.select{|account| account.status == "ACTIVE" && account.type == "BANK"}.first

    new_transaction = client.BankTransaction.build(
      :type => "ANYTHING_BUT_SPEND_OR_RECEIVE",
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

    assert false == new_transaction.save, "Expected save to fail"
    assert_equal "Invalid type. Expected either SPEND or RECEIVE.", new_transaction.errors_for(:type).first
  end

  must "supply supply a contact"
  must "supply one or more line items"
  must "supply a bank account"
end
