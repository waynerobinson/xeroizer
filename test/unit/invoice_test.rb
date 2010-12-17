require File.join(File.dirname(__FILE__), '../test_helper.rb')

class InvoiceTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @invoice = @client.Invoice.build
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
  
end