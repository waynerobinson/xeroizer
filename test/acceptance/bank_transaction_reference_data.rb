class BankTransactionReferenceData
  def initialize(client); @client = client; end
  def bank_transaction; @bank_transaction ||= new_bank_transaction; end

  private

  def new_bank_transaction
    all_accounts = @client.Account.all

    account = all_accounts.select{|acct| acct.status == "ACTIVE" && acct.type == "REVENUE"}.first
    bank_account = all_accounts.select{|acct| acct.status == "ACTIVE" && acct.type == "BANK"}.first
    
    result = @client.BankTransaction.build(
      :type => "SPEND",
      :contact => { :name => "Jazz Kang" },
      :line_items => [
        :description => "Bike shorts made of clear, unbreathable material",
        :quantity => 1,
        :unit_amount => 39.99,
        :account_code => account.code,
        :tax_type => account.tax_type
      ],
      :bank_account => { :account_id => bank_account.account_id }
    )

    fail("Expected save to have succeeded, but it failed. #{result.errors.inspect}") unless result.save

    result
  end
end
