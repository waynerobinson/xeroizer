require "test_helper"
require "acceptance_test"

class BulkOperationsTest < Test::Unit::TestCase
  include AcceptanceTest

  def random_name
    "test-person-#{rand 1000000000}"
  end

  def setup
    super
    @client = Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
  end

  can "create multiple invoices at once" do
    c1 = @client.Contact.build(name: random_name)
    c2 = @client.Contact.build(name: random_name)
    @client.Contact.save_all
    [c1, c2].each {|c| assert_false c.new_record? }
  end

  can "create and update new records in bulk" do
    c1 = @client.Contact.create(name: random_name)
    c1.email_address = "foo@bar.com"
    c2 = @client.Contact.build(name: random_name)
    @client.Contact.save_all
    [c1, c2].each {|c| assert_false c.new_record? }
    c1.download_complete_record!
    assert_equal c1.email_address, "foo@bar.com"
  end
end
