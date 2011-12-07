require "test_helper"

class BankTransactionTest < Test::Unit::TestCase
  include Xeroizer::Record

  must_eventually "calculate the total as the sum of its line item line_amount and tax_amount" do
    the_line_items = [
      LineItem.build({:quantity => 1, :tax_amount => 0.15, :unit_amount => 1.00, :tax_amount => 0.50}, nil),
      LineItem.build({:quantity => 1, :tax_amount => 0.15, :unit_amount => 1.00, :tax_amount => 0.50}, nil)
    ]

    fake_parent = Class.new do
      attr_accessor :application
    end.new

    the_bank_transaction = BankTransaction.new fake_parent
    the_bank_transaction.line_items = the_line_items

    expected_total = the_line_items.map do |line_item|
      BigDecimal(line_item[:line_amount].to_s) + BigDecimal(line_item[:tax_amount].to_s)
    end.reduce :+

    assert_equal expected_total, the_bank_transaction.total
  end

  must_eventually "calculate the sub_total assuming line item unit_price includes tax" do
    the_line_items = [
      LineItem.build({:quantity => 1, :tax_amount => 0.15, :unit_amount => 1.00, :tax_amount => 0.50}, nil),
    ]

    fake_parent = Class.new do
      attr_accessor :application
    end.new

    the_bank_transaction = BankTransaction.new fake_parent
    the_bank_transaction.line_items = the_line_items

    assert_equal 0.87, the_bank_transaction.sub_total
  end

  must "calculate the total tax as expected (based solely on the tax type)"
end
