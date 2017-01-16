require "test_helper"

class BankTransactionTest < Test::Unit::TestCase
  include Xeroizer::Record

  def setup

    the_line_items = [
      LineItem.build({:quantity => 1, :unit_amount => 1.00, :tax_amount => 0.50}, nil),
      LineItem.build({:quantity => 1, :unit_amount => 1.00, :tax_amount => 0.50}, nil)
    ]

    @the_bank_transaction = BankTransaction.new(nil)
    @the_bank_transaction.line_items = the_line_items
  end

  context "given a bank_transaction with line_amount_types set to \"Exclusive\"" do
    setup do
      @the_bank_transaction.line_amount_types = "Exclusive"
    end

    must "calculate the total as the sum of its line item line_amount and tax_amount" do
      assert_equal "3.0", @the_bank_transaction.total.to_s
    end

    must "calculate the sub_total as the sum of the line_amounts" do
      assert_equal "2.0", @the_bank_transaction.sub_total.to_s
    end
  end

  context "given a bank_transaction with line_amount_types set to \"Inclusive\"" do
    setup do
      @the_bank_transaction.line_amount_types = "Inclusive"
    end

    must "calculate the total as the sum of its line item line_amount and tax_amount" do
      assert_equal "2.0", @the_bank_transaction.total.to_s
    end

    must "calculate the sub_total as the sum of the line_amounts minus the total tax" do
      assert_equal "1.0", @the_bank_transaction.sub_total.to_s
    end
  end
end
