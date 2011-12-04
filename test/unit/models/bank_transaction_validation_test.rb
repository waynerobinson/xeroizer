require "test_helper"

class BankTransactionValidationTest < Test::Unit::TestCase
  must "supply either SPEND or RECEIVE as the type" do
    instance = Xeroizer::Record::BankTransaction.build({:type => "xxx"}, nil)
    
    assert false == instance.valid?, "Expected invalid because of invalid type"
    
    expected_error = "Invalid type, Expected either SPEND or RECEIVE."

    assert_equal expected_error, instance.errors_for(:type).first, "Expected an error about type"
  end
end
