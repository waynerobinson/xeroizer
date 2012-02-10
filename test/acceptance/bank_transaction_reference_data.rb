class BankTransactionReferenceData
  def initialize(client); @client = client; end
  def bank_transaction; @bank_transaction ||= new_bank_transaction; end

  private

  def new_bank_transaction
    all_accounts = @client.Account.all

    account = all_accounts.select{|account| account.status == "ACTIVE" && account.type == "REVENUE"}.first
    bank_account = all_accounts.select{|account| account.status == "ACTIVE" && account.type == "BANK"}.first

    result = @client.BankTransaction.build(
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

    fail("Expected save to have succeeded, but it failed. #{result.errors.inspect}") unless result.save

    result
  end
end
