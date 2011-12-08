require "test_helper"

class BankTransactionTest < Test::Unit::TestCase
  include Xeroizer::Record

  def setup
    fake_parent = Class.new do
      attr_accessor :application
    end.new

    the_line_items = [
      LineItem.build({:quantity => 1, :tax_amount => 0.15, :unit_amount => 1.00, :tax_amount => 0.50}, nil),
      LineItem.build({:quantity => 1, :tax_amount => 0.15, :unit_amount => 1.00, :tax_amount => 0.50}, nil)
    ]

    @the_bank_transaction = BankTransaction.new fake_parent
    @the_bank_transaction.line_items = the_line_items
  end

  context "given a bank_transaction where the line item amounts do not include tax" do
    setup do
      @the_bank_transaction.line_amount_type = "Exclusive"
    end

    must "calculate the total as the sum of its line item line_amount and tax_amount" do
      assert_equal "3.0", @the_bank_transaction.total.to_s
    end

    must "calculate the sub_total as the sum of the line_amounts" do
      assert_equal "2.0", @the_bank_transaction.sub_total.to_s
    end
  end

  context "given a bank_transaction where the line item amounts include tax" do
    setup do
      @the_bank_transaction.line_amount_type = "Inclusive"
    end

    must "calculate the total as the sum of its line item line_amount and tax_amount" do
      assert_equal "2.0", @the_bank_transaction.total.to_s
    end

    must "calculate the sub_total as the sum of the line_amounts minus the total tax" do
      assert_equal "1.0", @the_bank_transaction.sub_total.to_s
    end
  end
end
