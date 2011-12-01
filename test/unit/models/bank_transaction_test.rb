require "test_helper"

class BankTransactionTest < Test::Unit::TestCase
  def setup
    # See lib/xeroizer/record/base_model.rb
    @instance = Xeroizer::Record::BankTransactionModel.new(nil, "BankTransaction")
  end

  must "treat description as optional" do
    some_xml_with_no_description = "
     <Response>
        <BankTransactions>
          <BankTransaction>
            <Type>EXAMPLE_TYPE</Type>
            <Description />
          </BankTransaction>
        </BankTransactions>
    </Response>"

    result = @instance.parse_response(some_xml_with_no_description)

    assert_equal '', result.response_items.first.description
  end

  can "for example parse its type successfully from xml" do
    some_xml = "
     <Response>
        <BankTransactions>
          <BankTransaction>
            <Type>EXAMPLE_TYPE</Type>
          </BankTransaction>
        </BankTransactions>
    </Response>"

    result = @instance.parse_response(some_xml)

    assert_equal "EXAMPLE_TYPE", result.response_items.first.type
  end
end
