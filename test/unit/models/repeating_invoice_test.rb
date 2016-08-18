require 'test_helper'

class RepeatingInvoiceTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    mock_api('RepeatingInvoices')
  end

  context "GET" do

    should "have return repeating invoices" do
      repeating_invoices = @client.RepeatingInvoice.all(page: 1)

      assert_equal 1, repeating_invoices.size

      repeating_invoice = repeating_invoices.first

      assert_equal "PowerDirect", repeating_invoice.contact_name
      assert_equal BigDecimal.new(90), repeating_invoice.total
      assert_equal true, repeating_invoice.accounts_payable?

      schedule = repeating_invoice.schedule

      assert_equal 1, schedule.period
      assert_equal 'MONTHLY', schedule.unit
      assert_equal 10, schedule.due_date
      assert_equal 'OFFOLLOWINGMONTH', schedule.due_date_type
      assert_equal Date.new(2013,1,21), schedule.start_date
      assert_equal Date.new(2014,3,23), schedule.next_scheduled_date
    end

  end

end
