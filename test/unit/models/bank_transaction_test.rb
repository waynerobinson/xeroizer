require "test_helper"

class BankTransactionTest < Test::Unit::TestCase
  include Xeroizer::Record

  must "calculate the total as the sum of the line items correctly (including tax)" do 
    the_line_items = [
      {
        :quantity => 1,
        :unit_amount => 39.99,
        :tax_amount => 2.99
      },
      {
        :quantity => 1,
        :unit_amount => 9.99,
        :tax_amount => 0.99
      }
    ]

    fake_parent = Class.new do
      attr_accessor :application
    end.new

    the_bank_transaction = BankTransaction.new fake_parent
    the_bank_transaction.line_items = the_line_items

    expected_total = the_line_items.map do |line_item|
      item_total = line_item[:unit_amount].to_f + line_item[:tax_amount].to_f
      (item_total * line_item[:quantity].to_f).to_f
    end.reduce :+

    assert_equal expected_total, the_bank_transaction.total
  end

  must "calculate the total tax as expected (based solely on the tax type)"
end
