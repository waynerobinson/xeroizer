require "test_helper"

class LineItemTest < Test::Unit::TestCase
  include TestHelper
  include Xeroizer::Record
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
  end
  
  it "line_item tracking specified correctly" do
    invoice = @client.Invoice.build
    line_item = invoice.add_line_item({:description => "Test Description", :quantity => 1, :unit_amount => 200})
    
    line_item.add_tracking(:name => "Name 1", :option => "Option 1")
    line_item.add_tracking(:name => "Name 2", :option => "Option 2")
    
    doc = Nokogiri::XML(line_item.to_xml)
    assert_equal 2, doc.xpath("/LineItem/Tracking/TrackingCategory").size
  end

  it "line_amount equals unit_price times quantity" do
    line_item = LineItem.new(nil)

    line_item.quantity = 1
    line_item.unit_amount = BigDecimal("1337.00")
    line_item.tax_amount = BigDecimal("0.15")

    expected = BigDecimal((line_item.quantity * (line_item.unit_amount)).to_s).round(2)

    assert_equal expected.to_s, line_item.line_amount.to_s
  end

  it "line_amount is zero when quantity is nil or zero" do
    line_item = LineItem.new(nil)

    line_item.quantity = nil
    line_item.unit_amount = BigDecimal("1.00")
    line_item.tax_amount = BigDecimal("0.15")

    assert_equal "0.0", line_item.line_amount.to_s, "expected line amount zero when quantity is nil"

    line_item.quantity = 0
    assert_equal "0.0", line_item.line_amount.to_s, "expected line amount zero when quantity is zero"
  end

  it "is not possible to set unit_amount to zero" do
    line_item = LineItem.new(nil)

    line_item.quantity = 1
    line_item.unit_amount = nil
    line_item.tax_amount = BigDecimal("0.15")

    assert_equal 0.0, line_item.unit_amount,
      "Expected setting unit_amount to nil to be ignored, i.e., it should remain zero"
  end

  it "line_amount is zero when unit_amount is nil or zero" do
    line_item = LineItem.new(nil)

    line_item.quantity = 1
    line_item.unit_amount = nil
    line_item.tax_amount = BigDecimal("0.15")

    assert_equal "0.0", line_item.line_amount.to_s, "expected line amount zero when unit_amount is nil"

    line_item.unit_amount = BigDecimal("0.00")
    assert_equal "0.0", line_item.line_amount.to_s, "expected line amount zero when unit_amount is zero"
  end
end
