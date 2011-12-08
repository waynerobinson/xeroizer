require "test_helper"

class TaxExclusiveCalculator
  def self.total(line_items)
    sub_total(line_items) + total_tax(line_items)
  end

  def self.sub_total(line_items)
    line_items.inject(BigDecimal("0")) do |sum, item|
      sum += BigDecimal(item.line_amount.to_s).round(2)
    end
  end

  def self.total_tax(line_items)
    line_items.inject(BigDecimal("0")) do |sum, item|
      sum += BigDecimal(item.tax_amount.to_s).round(2)
    end
  end
end

class TaxExclusiveCalculatorTest < Test::Unit::TestCase
  include Xeroizer::Record

  def setup
    @the_line_items = [
      LineItem.build({:quantity => 1, :unit_amount => 1.00, :tax_amount => 0.15}, nil),
      LineItem.build({:quantity => 1, :unit_amount => 1.00, :tax_amount => 0.30}, nil)
    ]
  end

  it "sub_total is the sum of the line_amounts" do
    assert_equal BigDecimal("2.00"), TaxExclusiveCalculator.sub_total(@the_line_items)
  end

  it "total_tax is the sum of the tax_amounts" do
    assert_equal BigDecimal("0.45"), TaxExclusiveCalculator.total_tax(@the_line_items)
  end

  it "total is the sum of sub_total and total_tax" do
    assert_equal BigDecimal("2.45"), TaxExclusiveCalculator.total(@the_line_items)
  end
end
