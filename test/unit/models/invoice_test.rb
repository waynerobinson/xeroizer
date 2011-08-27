require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class InvoiceTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    mock_api('Invoices')
    @invoice = @client.Invoice.first
  end

  def build_valid_authorised_invoice
    @client.Invoice.build({
      :type => "ACCREC",
      :contact => { :name => "ABC Limited" },
      :status => "AUTHORISED",
      :date => Date.today,
      :due_date => Date.today,
      :line_items => [{
        :description => "Consulting services as agreed",
        :quantity => 0.005,
        :unit_amount => 1,
        :account_code => 200
      }]
    })
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
  
  context "invoice validations" do

    should "build an invalid invoice if there are no attributes" do
      assert_equal(false, @client.Invoice.build.valid?)
    end

    should "build a valid DRAFT invoice with minimal attributes" do
      invoice = @client.Invoice.build :type => "ACCREC", :contact => { :name => "ABC Limited" }
      assert_equal(true, invoice.valid?)
    end

    should "build a invalid AUTHORISED invoice with minimal attributes" do
      invoice = @client.Invoice.build :type => "ACCREC", :contact => { :name => "ABC Limited" }, :status => "AUTHORISED"
      assert_equal(false, invoice.valid?)
    end

    should "build a valid AUTHORISED invoice with complete attributes" do
      invoice = build_valid_authorised_invoice
      assert_equal(true, invoice.valid?)
    end

  end

  context "line items" do

    should "round line item amounts to two decimal places" do
      invoice = build_valid_authorised_invoice
      assert_equal(0.01, invoice.line_items.first.line_amount)
    end

  end
  
  context "contact shortcuts" do
    
    should "have valid #contact_name and #contact_id without downloading full invoice" do
      invoices = @client.Invoice.all
      invoices.each do |invoice|
        assert_not_equal("", invoice.contact_name)
        assert_not_equal("", invoice.contact_id)
        assert_equal(false, invoice.complete_record_downloaded?)
      end
    end
    
  end

end