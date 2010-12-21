require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class InvoiceTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @client.stubs(:http_get).with {|client, url, params| url =~ /Invoices$/ }.returns(get_record_xml(:invoices))
    @client.Invoice.all.each do | invoice |
      @client.stubs(:http_get).with {|client, url, params| url =~ /Invoices\/#{invoice.id}$/ }.returns(get_record_xml(:invoice, invoice.id))
    end
    @invoice = @client.Invoice.first
  end
  
  context "invoice types" do
    
    should "have helpers to determine invoice type" do
      @invoice.type = 'ACCREC'
      assert_equal(true, @invoice.accounts_receivable?)
      assert_equal(false, @invoice.accounts_payable?)

      @invoice.type = 'ACCPAY'
      assert_equal(false, @invoice.accounts_receivable?)
      assert_equal(true, @invoice.accounts_payable?)
    end
    
  end
  
  context "invoice totals" do
    
    should "raise error when trying to set totals directly" do
      assert_raises Xeroizer::SettingTotalDirectlyNotSupported do
        @invoice.sub_total = 100.0
      end
      assert_raises Xeroizer::SettingTotalDirectlyNotSupported do
        @invoice.total_tax = 100.0
      end
      assert_raises Xeroizer::SettingTotalDirectlyNotSupported do
        @invoice.total = 100.0
      end
    end
        
    should "large-scale testing from API XML" do
      invoices = @client.Invoice.all
      invoices.each do | invoice |
        assert_equal(invoice.attributes[:sub_total], invoice.sub_total)
        assert_equal(invoice.attributes[:total_tax], invoice.total_tax)
        assert_equal(invoice.attributes[:total], invoice.total)
      end
    end
    
  end
  
end