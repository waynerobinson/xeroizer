require "test_helper"

class BankAccountParsingTest < Test::Unit::TestCase
  def setup
    @instance = Xeroizer::Record::BankAccountModel.new(
      nil, 
      "BankAccount"
    )

    # TODO: why you need provide response and aggregate nodes element?
    @bank_account_xml = "
      <Response>
        <BankAccounts>
          <BankAccount>
            <AccountID>Phil Murphy's bike seat</AccountID>
            <Code>BANK</Code>
          </BankAccount>
        </BankAccounts>
      </Response>"
  end

  must "include account id" do
    result = @instance.parse_response @bank_account_xml 
    the_bank_account = result.response_items.first
    
    assert_equal "Phil Murphy's bike seat", the_bank_account.account_id, 
      "Unexpected account id: #{the_bank_account}"
  end

  must "include code" do 
    result = @instance.parse_response @bank_account_xml 
    the_bank_account = result.response_items.first
    
    assert_equal "BANK", the_bank_account.code, 
      "Unexpected code: #{the_bank_account}"
  end
end
