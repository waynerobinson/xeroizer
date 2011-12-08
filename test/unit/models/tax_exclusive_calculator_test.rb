require "test_helper"

class TaxCalculator
  def sub_total(line_items)
    line_items.inject(BigDecimal("0")) do |sum, item|
      sum += item.line_amount
    end
  end
end

class TaxCalculatorTest < Test::Unit::TestCase
  include Xeroizer::Record

  it "sub_total is the sum of the line_amounts" do
    the_line_items = [
      LineItem.build({:quantity => 1, :unit_amount => 1.00}, nil),
      LineItem.build({:quantity => 1, :unit_amount => 1.00}, nil)
    ]

    expected_sub_total = the_line_items.map do |line_item|
      BigDecimal(line_item[:line_amount].to_s)
    end.reduce :+

    assert_equal expected_sub_total, TaxCalculator.new.sub_total(the_line_items)
  end
end
