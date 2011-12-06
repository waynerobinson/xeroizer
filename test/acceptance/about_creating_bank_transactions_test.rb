require "test_helper"
require "acceptance_test"

class AboutCreatingBankTransactions < Test::Unit::TestCase
  include AcceptanceTest

  def client
    @client ||=  Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
  end

  can "create a new SPEND bank transaction" do
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
    assert_exists new_transaction
  end

  can "create a new RECEIVE bank transaction" do
    all_accounts = client.Account.all

    account = all_accounts.select{|account| account.status == "ACTIVE" && account.type == "REVENUE"}.first
    bank_account = all_accounts.select{|account| account.status == "ACTIVE" && account.type == "BANK"}.first

    new_transaction = client.BankTransaction.build(
      :type => "RECEIVE",
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
    assert_exists new_transaction
  end

  def assert_exists(bank_transaction)
    assert_not_nil bank_transaction.id,
      "Cannot check for exitence unless the bank transaction has non-null identifier"
    assert_not_nil client.BankTransaction.find bank_transaction.id
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
end
