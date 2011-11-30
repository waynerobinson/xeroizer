require File.expand_path File.join(File.dirname(__FILE__), "..", "test_helper")

module Xeroizer
  module Record
    class BankTransactionModel < BaseModel
      set_permissions :read
    end

    class BankTransaction < Base
      string :type
    end
  end
end

Xeroizer::GenericApplication.class_eval do
  record :BankTransaction
end

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

  can "for example, connect and fetch contacts" do
    client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)

    assert(client.Contact.all.size > 0, "Expected at least one contact")
  end

  can "get all bank transactions" do
    client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
    assert(client.BankTransaction.all.size > 0, "Expected at least one bank transaction")
  end
end
