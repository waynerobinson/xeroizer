require "test_helper"

class BankTransactionModelParsingTest < Test::Unit::TestCase
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

    assert_equal Date.parse("2010-07-30T00:00:00"), result.response_items.first.date
    assert_equal "Inclusive", result.response_items.first.line_amount_types
    assert_equal 15.00, result.response_items.first.sub_total
    assert_equal 0.00, result.response_items.first.total_tax
    assert_equal Date.parse("2008-02-20T12:19:56.657"), result.response_items.first.updated_date_utc
    assert_equal Date.parse("2010-07-30T00:00:00"), result.response_items.first.fully_paid_on_date
    assert_equal "d20b6c54-7f5d-4ce6-ab83-55f609719126", result.response_items.first.bank_transaction_id
    assert_equal "SPEND", result.response_items.first.type
    assert result.response_items.first.reconciled?, "Expected reconciled to be true"
  end
end
