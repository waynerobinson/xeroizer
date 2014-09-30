require 'test_helper'

class RecordAssociationTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    mock_api('Invoices')
    @client.stubs(:http_put).returns(get_record_xml(:invoice, "762aa45d-4632-45b5-8087-b4f47690665e"))
  end
  
  context "belongs_to association" do
    
    should "auto-load complete record if summary" do
      invoice = @client.Invoice.first
      assert_nil(invoice.attributes[:contact].contact_status)
      assert_equal(false, invoice.complete_record_downloaded?)
      assert_not_nil(invoice.contact.contact_status)
      assert_equal(true, invoice.complete_record_downloaded?)
    end
    
  end
  
  context "has_many association" do
    
    should "auto-load complete records if summary" do
      invoice = @client.Invoice.first
      assert_nil(invoice.attributes[:line_items])
      assert_equal(false, invoice.complete_record_downloaded?)
      assert(invoice.line_items.size > 0, "There should be one or more line items.")
      assert_equal(true, invoice.complete_record_downloaded?)
    end
    
    should "auto-build belongs_to item when passed hash" do
      invoice = @client.Invoice.build
      assert_nil(invoice.contact)
      invoice.contact = {:name => "Test Contact"}
      assert_kind_of(Xeroizer::Record::Contact, invoice.contact)
      assert_equal("Test Contact", invoice.contact.name)
    end
    
    should "auto-build has_many items when passed hash" do
      contact = @client.Contact.build
      assert_equal([], contact.phones)
      contact.phones = {:type => "DEFAULT", :number => "1234"}
      assert_kind_of(Xeroizer::Record::Phone, contact.phones.first)
      assert_equal("1234", contact.phones.first.number)
    end
    
    should "auto-build has_many items when passed array" do
      contact = @client.Contact.build
      assert_equal([], contact.phones)
      
      data = [
        {:type => "DEFAULT", :number => "1111"},
        {:type => "FAX", :number => "2222"}
      ]
      contact.phones = data.dup

      assert_equal(2, contact.phones.size)
      contact.phones.each_with_index do | phone, index | 
        assert_kind_of(Xeroizer::Record::Phone, phone)
        assert_equal(data[index][:number], phone.number)
      end
    end
    
    should "retain unsaved items after create" do
      invoice = @client.Invoice.build :type => "ACCREC", :contact => { :name => "A" }
      invoice.save
      invoice.add_line_item :description => "1"
      assert_equal(1, invoice.line_items.size, "There should be one line item.")
    end

    should "retain unsaved items after find" do
      invoice = @client.Invoice.find "762aa45d-4632-45b5-8087-b4f47690665e"
      invoice.add_line_item :description => "1"
      assert_equal(1, invoice.line_items.size, "There should be one line item.")
    end

    should "retain unsaved items after summary find" do
      invoice = @client.Invoice.all.last
      invoice.add_line_item :description => "1"
      assert_equal(1, invoice.line_items.size, "There should be one line item.")
    end

    should "retain unsaved items when set explicitly" do
      invoice = @client.Invoice.all.last
      invoice.line_items = [{ :description => "1" }]
      assert_equal(1, invoice.line_items.size, "There should be one line item.")
    end
  end
  
end
