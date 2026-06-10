# frozen_string_literal: true

require 'integration_test_case'

class BulkOperationsTest < IntegrationTestCase
  def random_name
    "test-person-#{rand 1_000_000_000}"
  end

  def setup
    @client = oauth2_client
  end

  should 'create multiple invoices at once' do
    c1 = nil
    c2 = nil
    assert(
      @client.Contact.batch_save do
        c1 = @client.Contact.build(name: random_name)
        c2 = @client.Contact.build(name: random_name)
      end
    )
    [c1, c2].each { |c| refute c.new_record? }
  end

  can 'create and update new records in bulk' do
    c1 = nil
    c2 = nil
    assert(
      @client.Contact.batch_save do
        c1 = @client.Contact.create(name: random_name)
        c1.email_address = 'foo@bar.com'
        c2 = @client.Contact.build(name: random_name)
      end
    )
    [c1, c2].each { |c| refute c.new_record? }
    c1.download_complete_record!
    assert_equal c1.email_address, 'foo@bar.com'
  end

  can 'return false from #batch_save if validation fails' do
    refute(
      @client.Contact.batch_save do
        @client.Contact.build(email_address: 'guy-with-no-name@example.com')
      end
    )
  end
end
