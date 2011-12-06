require "test_helper"
require "acceptance_test"

class AboutCreatingBankTransactions < Test::Unit::TestCase
  include AcceptanceTest

  def client
    @client ||=  Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
  end

  def setup
    super
    all_accounts = client.Account.all
    @account = all_accounts.select{|account| account.status == "ACTIVE" && account.type == "REVENUE"}.first
    @bank_account = all_accounts.select{|account| account.status == "ACTIVE" && account.type == "BANK"}.first
  end

  can "create a new SPEND bank transaction" do
    new_transaction = client.BankTransaction.build(
      :type => "SPEND",
      :contact => { :name => "Jazz Kang" },
      :line_items => any_line_items(@account),
      :bank_account => { :code => @bank_account.code }
    )

    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"
    assert_exists new_transaction
  end

  can "update a SPEND bank transaction, for example by setting its status" do
    new_transaction = client.BankTransaction.build(
      :type => "SPEND",
      :contact => { :name => "Jazz Kang" },
      :line_items => any_line_items(@account),
      :bank_account => { :code => @bank_account.code }
    )

    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"
    assert_exists new_transaction

    the_new_type = "RECEIVE"

    expected_id = new_transaction.id

    new_transaction.type = type = the_new_type

    assert new_transaction.save, "Update failed with the following errors: #{new_transaction.errors.inspect}"

    assert_equal expected_id, new_transaction.id, "Expected the id to be the same because it has been updated"

    refreshed_bank_transaction = client.BankTransaction.find expected_id

    assert_equal the_new_type, refreshed_bank_transaction.type,
      "Expected the bank transaction to've had its type updated"
  end

  must_eventually "update a bank transaction, for example by adding line items" do
    new_transaction = client.BankTransaction.build(
      :type => "SPEND",
      :contact => { :name => "Jazz Kang" },
      :line_items => any_line_items(@account),
      :bank_account => { :code => @bank_account.code }
    )

    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"
    assert_exists new_transaction

    expected_id = new_transaction.id

    the_new_line_items = [
      {
        :item_code => "Burrito skin",
        :description => "The outside of a burrito",
        :quantity => 1,
        :unit_amount => 39.99,
        :account_code => @account.code,
        :tax_type => @account.tax_type
      },
      {
        :item_code => "Dental pick (30)",
        :description => "Some things for picking lunch out of teeth",
        :quantity => 1,
        :unit_amount => 9.99,
        :account_code => @account.code,
        :tax_type => @account.tax_type
      }
    ]

    new_transaction.line_items = the_new_line_items

    assert new_transaction.save, "Update failed with the following errors: #{new_transaction.errors.inspect}"

    refreshed_bank_transaction = client.BankTransaction.find expected_id

    assert_equal expected_id, new_transaction.id,
      "Expected the id to be the same because it has been updated"

    assert_equal the_new_line_items, refreshed_bank_transaction.line_items,
      "Expected the bank transaction to've had its line items updated"
  end

  can "create a new RECEIVE bank transaction" do
    new_transaction = client.BankTransaction.build(
      :type => "RECEIVE",
      :contact => { :name => "Jazz Kang" },
      :line_items => any_line_items(@account),
      :bank_account => { :code => @bank_account.code }
    )

    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"
    assert_exists new_transaction
  end

  def assert_exists(bank_transaction)
    assert_not_nil bank_transaction.id,
      "Cannot check for exitence unless the bank transaction has non-null identifier"
    assert_not_nil client.BankTransaction.find bank_transaction.id
  end

  def any_line_items(account)
    [{
      :item_code => "Clingfilm bike shorts",
      :description => "Bike shorts made of clear, unbreathable material",
      :quantity => 1,
      :unit_amount => 39.99,
      :account_code => account.code,
      :tax_type => account.tax_type
    }]
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
