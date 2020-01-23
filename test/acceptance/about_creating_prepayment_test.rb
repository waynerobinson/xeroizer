require "test_helper"
require "acceptance_test"

class AboutCreatingPrepayment < Test::Unit::TestCase
  include AcceptanceTest

  def any_line_items(account)
    [{
         :description => "Clingfilm bike shorts",
         :quantity => 1,
         :unit_amount => "200.00",
         :account_code => account.code,
         :tax_type => account.tax_type
     }]
  end

  def assert_exists(prepayment, client)
    assert_not_nil prepayment.id,
                   "Cannot check for exitence unless the prepayment (bank transaction) has non-null identifier"
    assert_not_nil client.BankTransaction.find prepayment.id
  end

  setup do
    @client = AcceptanceTestHelpers.oauth2_client
    all_accounts = @client.Account.all
    @account = all_accounts.select{|acct| acct.status == "ACTIVE" && acct.type == "REVENUE"}.first
    @bank_account = all_accounts.select{|acct| acct.status == "ACTIVE" && acct.type == "BANK"}.first
  end

  can "create a new PrePayment bank transaction" do
    new_transaction = @client.BankTransaction.build(
        :type => "RECEIVE-PREPAYMENT",
        :contact => { :name => "Jazz Kang" },
        :line_items => any_line_items(@account),
        :bank_account => { :account_id => @bank_account.account_id }
    )

    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"
    assert_exists new_transaction, @client
  end
end
