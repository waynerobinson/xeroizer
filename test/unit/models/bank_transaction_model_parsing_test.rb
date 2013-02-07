require "test_helper"

class BankTransactionModelParsingTest < Test::Unit::TestCase
  def setup
    # See lib/xeroizer/record/base_model.rb
    @instance = Xeroizer::Record::BankTransactionModel.new(nil, "BankTransaction")
  end

  must "parse all the root elements except sub_total, total_tax and total" do
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

    the_bank_transaction = result.response_items.first

    assert_equal Date.parse("2010-07-30T00:00:00"), the_bank_transaction.date
    assert_equal "Inclusive", the_bank_transaction.line_amount_types

    assert_equal(Time.parse("2008-02-20T12:19:56.657Z"), the_bank_transaction.updated_date_utc)
    
    assert_equal Date.parse("2010-07-30T00:00:00"), the_bank_transaction.fully_paid_on_date
    assert_equal "d20b6c54-7f5d-4ce6-ab83-55f609719126", the_bank_transaction.bank_transaction_id
    assert_equal "SPEND", the_bank_transaction.type
    assert the_bank_transaction.reconciled?, "Expected reconciled to be true"
  end

  must "parse the contact" do
    some_xml_with_a_contact = "
     <Response>
        <BankTransactions>
          <BankTransaction>
            <Contact>
              <ContactID>c09661a2-a954-4e34-98df-f8b6d1dc9b19</ContactID>
              <ContactStatus>ACTIVE</ContactStatus>
              <Name>BNZ</Name>
              <Addresses>
                <Address>
                  <AddressType>POBOX</AddressType>
                </Address>
                <Address>
                  <AddressType>STREET</AddressType>
                </Address>
              </Addresses>
              <Phones>
                <Phone>
                  <PhoneType>MOBILE</PhoneType>
                </Phone>
              </Phones>
              <UpdatedDateUTC>2010-09-17T19:26:39.157</UpdatedDateUTC>
            </Contact>
          </BankTransaction>
        </BankTransactions>
    </Response>"

    result = @instance.parse_response(some_xml_with_a_contact)
    the_bank_transaction = result.response_items.first
    the_contact = the_bank_transaction.contact

    assert_equal(
      "c09661a2-a954-4e34-98df-f8b6d1dc9b19",
      the_contact.contact_id,
      "Mismatched contact id for contact: #{the_contact.inspect}"
    )
  end

  must "parse the correct number of line items" do
    some_xml_with_a_line_item = "
     <Response>
        <BankTransactions>
          <BankTransaction>
            <LineItems>
              <LineItem>
                <Description>Monthly account fee</Description>
                <UnitAmount>15</UnitAmount>
                <TaxType>NONE</TaxType>
                <TaxAmount>0.00</TaxAmount>
                <LineAmount>15.00</LineAmount>
                <AccountCode>404</AccountCode>
                <Quantity>1.0000</Quantity>
              </LineItem>
            </LineItems>
          </BankTransaction>
        </BankTransactions>
    </Response>"

    result = @instance.parse_response(some_xml_with_a_line_item)
    the_bank_transaction = result.response_items.first

    assert_equal(1, the_bank_transaction.line_items.size,
      "Mismatched number of line items: #{the_bank_transaction.inspect}"
    )
  end

  must "parse the bank account" do
    some_xml_with_a_bank_account = "
     <Response>
        <BankTransactions>
          <BankTransaction>
            <BankAccount>
              <AccountID>297c2dc5-cc47-4afd-8ec8-74990b8761e9</AccountID>
              <Code>BANK</Code>
            </BankAccount>
          </BankTransaction>
        </BankTransactions>
    </Response>"

    result = @instance.parse_response(some_xml_with_a_bank_account)
    the_bank_transaction = result.response_items.first

    assert_not_nil(the_bank_transaction.bank_account,
      "Missing bank_account: #{the_bank_transaction.inspect}"
    )

    assert_equal "297c2dc5-cc47-4afd-8ec8-74990b8761e9", the_bank_transaction.bank_account.account_id,
      "Unexpected bank account id: #{the_bank_transaction.inspect}"
  end
end
