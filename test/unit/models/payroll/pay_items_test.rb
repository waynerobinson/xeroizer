require 'test_helper'

class PayItemsTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET).payroll
    mock_api('PayItems')
  end

  test "get all" do
    pay_items = @client.PayItem.first
    assert_equal 4, pay_items.earnings_rates.size
    assert_equal 5, pay_items.deduction_types.size
    assert_equal 2, pay_items.reimbursement_types.size
    assert_equal 9, pay_items.leave_types.size

    doc = Nokogiri::XML pay_items.to_xml
    assert_equal 4, doc.xpath("/PayItems/EarningsRates/EarningsRate").size
    assert_equal 5, doc.xpath("/PayItems/DeductionTypes/DeductionType").size
    assert_equal 2, doc.xpath("/PayItems/ReimbursementTypes/ReimbursementType").size
    assert_equal 9, doc.xpath("/PayItems/LeaveTypes/LeaveType").size
  end
end
