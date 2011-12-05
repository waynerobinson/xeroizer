require "test_helper"

class AboutBankTransactions < Test::Unit::TestCase
  def setup
    assert_not_nil ENV["CONSUMER_KEY"], "No CONSUMER_KEY environment variable specified."
    assert_not_nil ENV["CONSUMER_SECRET"], "No CONSUMER_SECRET environment variable specified."
    assert_not_nil ENV["KEY_FILE"], "No KEY_FILE environment variable specified."
    assert File.exists?(ENV["KEY_FILE"]), "The file <#{ENV["KEY_FILE"]}> does not exist."
    @key_file = ENV["KEY_FILE"]
    @consumer_key = ENV["CONSUMER_KEY"]
    @consumer_secret = ENV["CONSUMER_SECRET"]
  end
  
  context "when requesting all bank transactions (i.e., without filter)" do
    setup do 
      client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
      @the_bank_transactions = client.BankTransaction.all
      @the_first_bank_transaction = @the_bank_transactions.first
    end

    it "returns line items empty" do 
      assert_empty(@the_first_bank_transaction.line_items, "Expected line items to've been excluded")
    end

    it "returns contact with name and and id ONLY (no addresses or phones)" do 
      the_contact = @the_first_bank_transaction.contact
      assert_not_nil(the_contact.contact_id, "Expected contact id to be present")
      assert_not_nil(the_contact.name, "Expected contact name to be present")
      assert_empty the_contact.phones, "Expected empty contact phones"
      assert_empty the_contact.addresses, "Expected empty contact addresses"
    end

    it "returns the bank account" do
      assert_not_nil @the_first_bank_transaction.bank_account
    end
  end

  context "when requesting a single bank transaction for example" do
    it "returns expanded contacts and addresses"
    it "returns full line item details"
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

  can "fetch all accounts" do
    client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
    all = client.Account.all

    assert all.size > 0
  end

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

  must "supply either SPEND or RECEIVE as the type"
  must "supply supply a contact"
  must "supply one or more line items"
  must "supply a bank account"
end
