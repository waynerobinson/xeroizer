require "test_helper"
require "acceptance_test"

class BankTransfer < Test::Unit::TestCase
  include AcceptanceTest

  let(:clients) { [oauth_client] }
  let(:oauth_client) { Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file) }
  let(:oauth2_client) { Xeroizer::OAuth2Application.new(@client_key, @client_secret, access_token: @access_token, tenant_id: @tenant_id) }

  def create_a_bank_transfer(client)
    all_accounts = client.Account.all
    @from_bank_account = all_accounts.select { |acct| acct.status == "ACTIVE" && acct.type == "BANK" }.first
    @to_bank_account = all_accounts.select { |acct| acct.status == "ACTIVE" && acct.type == "BANK" }.last

    new_transfer = client.BankTransfer.build(
      :amount => 300,
      :from_bank_account => { :account_id => @from_bank_account.account_id },
      :to_bank_account => { :account_id => @to_bank_account.account_id }
    )
    assert new_transfer.save, "Save failed with the following errors: #{new_transfer.errors.inspect}"
  end

  can "create a bank" do
    clients.each { |client| create_a_bank_transfer(client) }
  end
end
