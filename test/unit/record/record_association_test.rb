require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class RecordAssociationTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @client.stubs(:http_get).with {|client, url, params| url =~ /Invoices\/[^\/]+$/ }.returns(get_record_xml(:invoice))
    @client.stubs(:http_get).with {|client, url, params| url =~ /Invoices$/ }.returns(get_record_xml(:invoices))
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
    
  end
  
end
