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

  include Xeroizer::Record

  must "calculate the total as the sum of the line items correctly (including tax)" do 
    the_line_items = [
      {
        :quantity => 1,
        :unit_amount => 39.99,
        :tax_amount => 2.99
      },
      {
        :quantity => 1,
        :unit_amount => 9.99,
        :tax_amount => 0.99
      }
    ]

    fake_parent = Class.new do
      attr_accessor :application
    end.new

    the_bank_transaction = BankTransaction.new fake_parent
    the_bank_transaction.line_items = the_line_items

    expected_total = the_line_items.map do |line_item|
      item_total = line_item[:unit_amount].to_f + line_item[:tax_amount].to_f
      (item_total * line_item[:quantity].to_f).to_f
    end.reduce :+

    assert_equal expected_total, the_bank_transaction.total
  end

  must "calculate the total tax as expected (based solely on the tax type)"
end
