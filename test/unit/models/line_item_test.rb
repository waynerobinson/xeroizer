require "test_helper"

class LineItemTest < Test::Unit::TestCase
  include Xeroizer::Record

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
