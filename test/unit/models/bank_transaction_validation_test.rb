require "test_helper"

class BankTransactionValidationTest < Test::Unit::TestCase
  include Xeroizer::Record

  must "supply either SPEND or RECEIVE as the type" do
    instance = BankTransaction.build({:type => "xxx"}, nil)

    assert false == instance.valid?, "Expected invalid because of invalid type"

    expected_error = "Invalid type. Expected either SPEND, RECEIVE, RECEIVE-PREPAYMENT or RECEIVE-OVERPAYMENT."

    assert_equal expected_error, instance.errors_for(:type).first, "Expected an error about type"

    instance = BankTransaction.build({:type => "SPEND"}, nil)

    instance.valid?

    assert_empty instance.errors_for(:type), "Expected no error about type"

    instance = BankTransaction.build({:type => "RECEIVE"}, nil)

    instance.valid?

    assert_empty instance.errors_for(:type), "Expected no error about type"
  end

  can "omit the status attribute" do
    instance = BankTransaction.build({}, nil)
    instance.valid?
    assert_empty instance.errors_for(:status), "Expected no error about status"
  end

  must "supply either AUTHORISED or DELETED as the status" do
    instance = BankTransaction.build({:status => "xxx"}, nil)

    assert false == instance.valid?, "Expected invalid because of invalid status"

    expected_error = "not one of AUTHORISED, DELETED"

    assert_equal expected_error, instance.errors_for(:status).first, "Expected an error about status"

    instance = BankTransaction.build({:status => "AUTHORISED"}, nil)

    instance.valid?

    assert_empty instance.errors_for(:status), "Expected no error about status"

    instance = BankTransaction.build({:status => "DELETED"}, nil)

    instance.valid?

    assert_empty instance.errors_for(:status), "Expected no error about status"
  end

  must "supply a non-blank contact" do
    instance = BankTransaction.build({}, nil)

    assert false == instance.valid?, "Expected invalid because of missing contact"

    assert_equal "can't be blank", instance.errors_for(:contact).first,
      "Expected an error about blank contact"
  end

  must "supply at least one line item" do
    zero_line_items = []

    instance = BankTransaction.build({:line_items => zero_line_items}, nil)

    assert false == instance.valid?, "Expected invalid because of empty line items"

    assert_equal "Invalid line items. Must supply at least one.", instance.errors_for(:line_items).first,
      "Expected an error about blank line items"

    one_line_item = [LineItem.build({}, nil)]

    instance.errors.clear
    instance.line_items = one_line_item

    assert_empty instance.errors_for(:line_items), "expected no errors for one line item, #{instance.errors_for(:line_items)}"

    more_than_one_line_item = [LineItem.build({}, nil), LineItem.build({}, nil)]

    instance.errors.clear
    instance.line_items = more_than_one_line_item

    assert_empty instance.errors_for(:line_items), "expected no errors for more than one line item, #{instance.errors_for(:line_items)}"
  end

  must "supply a non-blank bank account" do
    instance = BankTransaction.build({}, nil)

    assert false == instance.valid?, "Expected invalid because of missing bank account"

    assert_equal "can't be blank", instance.errors_for(:bank_account).first,
      "Expected an error about blank contact"
  end

  must "supply valid line_amount_types value" do
    instance = BankTransaction.build({
      :line_amount_types => "XXX_ANYTHING_INVALID_XXX"
    }, nil)

    assert false == instance.valid?, "Expected invalid because of missing bank account"

    assert_equal "not one of Exclusive, Inclusive, NoTax", instance.errors_for(:line_amount_types).first,
      "Expected an error about blank contact"
  end

  must "line_amount_type defaults to \"Exclusive\"" do
    instance = BankTransaction.build({}, nil)

    assert_equal "Exclusive", instance.line_amount_types
  end
end
