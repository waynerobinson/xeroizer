require "test_helper"
require "acceptance_test"
require "shoulda/matchers"

include Shoulda::Matchers

class BulkOperationsTest < Test::Unit::TestCase
  include AcceptanceTest

  def random_name
    "test-person-#{rand 1000000000}"
  end

  setup do
    @client = AcceptanceTestHelpers.oauth2_client
  end

  should "create multiple invoices at once" do
    c1, c2 = nil, nil
    assert_true(
        @client.Contact.batch_save do
          c1 = @client.Contact.build(name: random_name)
          c2 = @client.Contact.build(name: random_name)
        end
    )
    [c1, c2].each {|c| assert_false c.new_record? }
  end

  can "create and update new records in bulk" do
    c1, c2 = nil, nil
    assert_true(
        @client.Contact.batch_save do
          c1 = @client.Contact.create(name: random_name)
          c1.email_address = "foo@bar.com"
          c2 = @client.Contact.build(name: random_name)
        end
    )
    [c1, c2].each {|c| assert_false c.new_record? }
    c1.download_complete_record!
    assert_equal c1.email_address, "foo@bar.com"
  end

  can "return false from #batch_save if validation fails" do
    assert_false(
        @client.Contact.batch_save do
          @client.Contact.build(email_address: "guy-with-no-name@example.com")
        end
    )
  end
end
