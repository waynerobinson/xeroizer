require "test_helper"
require "acceptance_test"

class BankTransfer < Test::Unit::TestCase
  include AcceptanceTest

  let :client do
    Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
  end

  def setup
    super
    all_accounts = client.Account.all
    @from_bank_account = all_accounts.select { |acct| acct.status == "ACTIVE" && acct.type == "BANK" }.first
    @to_bank_account = all_accounts.select { |acct| acct.status == "ACTIVE" && acct.type == "BANK" }.last
  end

  can "create a bank transfer" do
    new_transfer = client.BankTransfer.build(
      :amount => 300,
      :from_bank_account => { :account_id => @from_bank_account.account_id },
      :to_bank_account => { :account_id => @to_bank_account.account_id }
    )
    assert new_transfer.save, "Save failed with the following errors: #{new_transfer.errors.inspect}"
  end
end
