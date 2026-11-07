require "integration_test_case"

class BankTransferTest < IntegrationTestCase
  can "create a bank transfer" do
    banks = oauth2_client.Account.all.select { |acct| acct.status == "ACTIVE" && acct.type == "BANK" }
    transfer = oauth2_client.BankTransfer.build(
      amount: 300,
      from_bank_account: { account_id: banks.first.account_id },
      to_bank_account: { account_id: banks.last.account_id }
    )
    assert transfer.save, "Save failed with the following errors: #{transfer.errors.inspect}"
  end
end
