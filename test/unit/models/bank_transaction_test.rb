require "test_helper"

class BankTransactionTest < Test::Unit::TestCase
  def setup
    # See lib/xeroizer/record/base_model.rb
    @instance = Xeroizer::Record::BankTransactionModel.new(nil, "BankTransaction")
  end

  must "parse the root elements from XML" do
    some_xml = "
     <Response>
        <BankTransactions>
          <BankTransaction>
            <Date>2010-07-30T00:00:00</Date>
            <LineAmountTypes>Inclusive</LineAmountTypes>
            <SubTotal>15.00</SubTotal>
            <TotalTax>0.00</TotalTax>
            <Total>15.00</Total>
            <UpdatedDateUTC>2008-02-20T12:19:56.657</UpdatedDateUTC>
            <FullyPaidOnDate>2010-07-30T00:00:00</FullyPaidOnDate>
            <BankTransactionID>d20b6c54-7f5d-4ce6-ab83-55f609719126</BankTransactionID>
            <Type>SPEND</Type>
            <IsReconciled>true</IsReconciled>
          </BankTransaction>
        </BankTransactions>
    </Response>"

    result = @instance.parse_response(some_xml)

    assert_equal "SPEND", result.response_items.first.type
    assert_equal Date.parse("2010-07-30T00:00:00"), result.response_items.first.date
  end
end
