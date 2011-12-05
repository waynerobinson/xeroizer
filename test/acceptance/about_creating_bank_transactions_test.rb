require "test_helper"
require "acceptance_test"

class AboutCreatingBankTransactions < Test::Unit::TestCase
  include AcceptanceTest

  must_eventually "create new bank transactions" do
    client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)

    account = client.Account.all.first

    new_transaction = client.BankTransaction.build(
      :type => "SPEND", 
      :contact => { :name => "Jazz Kang" },
      :account_code => account.code,
      :tax_type => "XXX", 
      :line_items => [
        :item_code => "xxx", 
        :description => "description",
        :quantity => 1.0,
        :unit_amount => 3.99
      ], 
      :bank_account => { :code => account.code }
    )
    
    assert new_transaction.save, "Save failed with the following errors: #{new_transaction.errors.inspect}"

    puts new_transaction.inspect
  end

  it "fails with RuntimeError when you try and create a new bank account" do 
    client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
    
    new_account = client.Account.build(
      :name => "Example bank account",  
      :code => "ACC-001"                                         
    )
    
    assert_raise RuntimeError do 
      new_account.save
    end
  end

  must "supply either SPEND or RECEIVE as the type"
  must "supply supply a contact"
  must "supply one or more line items"
  must "supply a bank account"
end
