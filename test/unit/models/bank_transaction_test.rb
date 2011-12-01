require "test_helper"

class BankTransactionTest < Test::Unit::TestCase
  must "treat description as optional"

  can "for example parse its type successfully from xml" do
    some_xml = "
     <Response>
        <BankTransactions>
          <BankTransaction>
            <Type>EXAMPLE_TYPE</Type>
          </BankTransaction>
        </BankTransactions>
    </Response>"

    # See lib/xeroizer/record/base_model.rb
    instance = Xeroizer::Record::BankTransactionModel.new(nil, "BankTransaction")

    result = instance.parse_response(some_xml)

    assert_equal "EXAMPLE_TYPE", result.response_items.first.type
  end
end
