require "test_helper"
require "acceptance_test"

class AboutGetOnlineInvoiceUrl < Test::Unit::TestCase
  include AcceptanceTest

  let :client do
    Xeroizer::PrivateApplication.new(@consumer_key, @consumer_secret, @key_file)
  end

  def setup
  	super
  	@invoice = client.Invoice.all(:where => 'Type=="ACCREC"').first
  	@invoice_AccPay = client.Invoice.all(:where => 'Type=="ACCPAY"').first
  end

  can "Request OnlineInvoice of an AccRec invoice" do 
  	@onlineInvoice = @invoice.online_invoice

  	assert @onlineInvoice.online_invoice_url, "online_invoice_url not found"
  	assert @onlineInvoice.online_invoice_url.start_with?('https://in.xero.com/'), "online_invoice_url returned in unexpected format"
  end

  can "Not request OnlineInvoice of an AccPay invoice" do
  	assert_raise do
  	  @onlineInvoiceAccPay = @invoice_AccPay.online_invoice
  	end
  end
end