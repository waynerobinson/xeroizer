require "test_helper"
require "acceptance_test"

class BulkOperationsTest < Test::Unit::TestCase
  include AcceptanceTest

  def random_name
    "test-person-#{rand 1000000000}"
  end

  let(:clients) { [oauth_client, oauth2_client] }
  let(:oauth_client) { Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file) }
  let(:oauth2_client) { Xeroizer::OAuth2Application.new(@client_key, @client_secret, access_token: @access_token, tenant_id: @tenant_id) }

  should "test with each oauth type" do
    clients.each do |client|
      self.class.test_with_client(client)
    end
  end

  def self.test_with_client(client)
    can "create multiple invoices at once" do
      c1, c2 = nil, nil
      assert_true(
        client.Contact.batch_save do
          c1 = client.Contact.build(name: random_name)
          c2 = client.Contact.build(name: random_name)
        end
      )
      [c1, c2].each {|c| assert_false c.new_record? }
    end

    can "create and update new records in bulk" do
      c1, c2 = nil, nil
      assert_true(
        client.Contact.batch_save do
          c1 = client.Contact.create(name: random_name)
          c1.email_address = "foo@bar.com"
          c2 = client.Contact.build(name: random_name)
        end
      )
      [c1, c2].each {|c| assert_false c.new_record? }
      c1.download_complete_record!
      assert_equal c1.email_address, "foo@bar.com"
    end

    can "return false from #batch_save if validation fails" do
      assert_false(
        client.Contact.batch_save do
          client.Contact.build(email_address: "guy-with-no-name@example.com")
        end
      )
    end
  end
end
