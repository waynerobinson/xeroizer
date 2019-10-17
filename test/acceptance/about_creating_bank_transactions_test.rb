require "test_helper"
require "acceptance_test"

class AboutCreatingBankTransactions < Test::Unit::TestCase
  include AcceptanceTest

  let :client do
    Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
  end

  def setup
    super
    all_accounts = client.Account.all
    @account = all_accounts.select{|acct| acct.status == "ACTIVE" && acct.type == "REVENUE"}.first
    @bank_account = all_accounts.select{|acct| acct.status == "ACTIVE" && acct.type == "BANK"}.first    
  end

  can "create a new SPEND bank transaction" do
    new_transaction = client.BankTransaction.build(
      :type => "SPEND",
      :contact => { :name => "Jazz Kang" },
      :line_items => any_line_items(@account),
      :bank_account => { :account_id => @bank_account.account_id }
    )

    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"
    assert_exists new_transaction
  end

  can "update a SPEND bank transaction, for example by setting its status" do
    new_transaction = client.BankTransaction.build(
      :type => "SPEND",
      :contact => { :name => "Jazz Kang" },
      :line_items => any_line_items(@account),
      :bank_account => { :account_id => @bank_account.account_id }
    )

    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"

    assert_exists new_transaction

    the_new_type = "RECEIVE"

    expected_id = new_transaction.id

    new_transaction.type = the_new_type

    assert new_transaction.save, "Update failed with the following errors: #{new_transaction.errors.inspect}"

    assert_equal expected_id, new_transaction.id, "Expected the id to be the same because it has been updated"

    refreshed_bank_transaction = client.BankTransaction.find expected_id

    assert_equal the_new_type, refreshed_bank_transaction.type,
      "Expected the bank transaction to've had its type updated"
  end

  can "update a bank transaction by adding line items provided you calculate the tax_amount correctly" do
    new_transaction = client.BankTransaction.build(
      :type => "SPEND",
      :contact => { :name => "Jazz Kang" },
      :line_items => any_line_items(@account),
      :bank_account => { :account_id => @bank_account.account_id },
      :line_amount_types => "Exclusive"
    )

    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"
    assert_exists new_transaction

    expected_id = new_transaction.id

    tax_rate = get_tax_rate(@account.tax_type).effective_rate

    unit_price = BigDecimal("1337.00")

    the_new_line_items = [
      {
        :description => "Burrito skin",
        :quantity => 1,
        :unit_amount => unit_price,
        :account_code => @account.code,
        :tax_type => @account.tax_type,
        :tax_amount => get_exclusive_tax(unit_price, tax_rate)
      }
    ]

    new_transaction.line_items = the_new_line_items

    assert new_transaction.save, "Update failed with the following errors: #{new_transaction.errors.inspect}"

    refreshed_bank_transaction = client.BankTransaction.find expected_id

    assert_equal expected_id, new_transaction.id,
      "Expected the id to be the same because it has been updated"

    assert_equal 1, refreshed_bank_transaction.line_items.size,
      "Expected the bank transaction to've had its line items updated to just one"

    the_first_line_item = refreshed_bank_transaction.line_items.first

    assert_equal "Burrito skin", the_first_line_item.description,
      "Expected the bank transaction to've had its line items updated, " +
      "but the first one's description does not match: #{the_first_line_item.inspect}"
  end

  def get_inclusive_tax(amount, tax_rate)
    inclusive_tax = amount * (1 - (100/(100 + tax_rate)))
    BigDecimal(inclusive_tax.to_s).round(2)
  end

  def get_exclusive_tax(amount, tax_rate)
    exclusive_tax = amount * (tax_rate/100)
    BigDecimal(exclusive_tax.to_s).round(2)
  end

  def get_tax_rate tax_type
    @all_tax_types ||= client.TaxRate.all
    @all_tax_types.select{|tax_rate| tax_rate.tax_type == tax_type}.first
  end

  can "create a new RECEIVE bank transaction" do
    new_transaction = client.BankTransaction.build(
      :type => "RECEIVE",
      :contact => { :name => "Jazz Kang" },
      :line_items => any_line_items(@account),
      :bank_account => { :account_id => @bank_account.account_id }
    )

    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"
    assert_exists new_transaction
  end

  it "treats line item unit_amounts as tax EXCLUSIVE"
  must "not set the tax_amount manually on line items"

  def assert_exists(bank_transaction)
    assert_not_nil bank_transaction.id,
      "Cannot check for exitence unless the bank transaction has non-null identifier"
    assert_not_nil client.BankTransaction.find bank_transaction.id
  end

  def any_line_items(account)
    [{
      :description => "Clingfilm bike shorts",
      :quantity => 1,
      :unit_amount => "17.00",
      :account_code => account.code,
      :tax_type => account.tax_type
    }]
  end

  it "fails with ApiException when you try and create a new bank account with missing account type with save! method" do
    new_account = client.Account.build(
      :name => "Example bank account",
      :code => "ACC-001"
    )

    assert_raise Xeroizer::ApiException do
      new_account.save!
    end
  end

  it "returns false when you try and create a new bank account with a missing account type with save method" do
    new_account = client.Account.build(
      :name => "Example bank account",
      :code => "ACC-001"
    )

    assert new_account.save == false, "Account save method expected to return false"

  end
end
