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

  it "line_amount equals unit_price times quantity if there is no discount_rate" do
    line_item = LineItem.new(nil)

    line_item.quantity = 1
    line_item.unit_amount = BigDecimal("1337.00")

    assert_equal "1337.0", line_item.line_amount.to_s,
      "expected line_amount to equal unit_amount times quantity"
  end

  it "line_amount equals unit_amount times quantity minus the discount if there is a discount_rate" do
    line_item = LineItem.new(nil)
    line_item.quantity = 1
    line_item.unit_amount = BigDecimal("1337.00")
    line_item.discount_rate = BigDecimal("12.34")

    assert_equal "1172.01", line_item.line_amount.to_s,
      "expected line_amount to equal unit_amount times quantity minus the discount"
  end

  it "line_amount is zero when quantity is nil or zero" do
    line_item = LineItem.new(nil)

    line_item.quantity = nil
    line_item.unit_amount = BigDecimal("1.00")

    assert_equal "0.0", line_item.line_amount.to_s,
      "expected line amount to be zero when quantity is nil"

    line_item.quantity = 0
    assert_equal "0.0", line_item.line_amount.to_s,
      "expected line amount to be zero when quantity is zero"
  end

  it "is not possible to set unit_amount to zero" do
    line_item = LineItem.new(nil)

    line_item.unit_amount = nil

    assert_equal 0.0, line_item.unit_amount,
      "Expected setting unit_amount to nil to be ignored, i.e., it should remain zero"
  end

  it "line_amount is zero when unit_amount is nil or zero" do
    line_item = LineItem.new(nil)

    line_item.quantity = 1
    line_item.unit_amount = nil

    assert_equal "0.0", line_item.line_amount.to_s,
      "expected line amount to be zero when unit_amount is nil"

    line_item.unit_amount = BigDecimal("0.00")
    assert_equal "0.0", line_item.line_amount.to_s,
      "expected line amount to be zero when unit_amount is zero"
  end

  it "coerces decimals when calculating line amount" do
    line_item = LineItem.new(nil)
    line_item.quantity = "1"
    line_item.unit_amount = 50
    assert_equal 50, line_item.line_amount,
      "expected line amount to be calculated from coerced values"
  end
end
