require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class InvoiceTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @invoice = @client.Invoice.build
    @invoice.add_line_item(:description => "First Line", :quantity => 1, :unit_amount => 10, :account_code => '100', :tax_amount => 10, :tax_type => 'OUTPUT')
    @invoice.add_line_item(:description => "Second Line", :quantity => 2, :unit_amount => 20, :account_code => '100', :tax_amount => 20, :tax_type => 'OUTPUT')
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
    
    should "total up amounts correctly" do
      assert_equal(50, @invoice.sub_total)
      assert_equal(30, @invoice.total_tax)
      assert_equal(80, @invoice.total)
    end
    
    should "large-scale testing from API XML" do
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("invoices.xml"), :code => "200"))
      invoices = @client.Invoice.all
      invoices.each do | invoice |
        assert_equal(invoice.attributes[:sub_total], invoice.sub_total)
        assert_equal(invoice.attributes[:total_tax], invoice.total_tax)
        assert_equal(invoice.attributes[:total], invoice.total)
      end
    end
    
  end
  
end