require 'test_helper'

class ContactTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
  end

  context "contact validators" do
    should "have a name" do
      contact = @client.Contact.build

      assert_equal(false, contact.valid?)
      blank_error = contact.errors_for(:name).first
      assert_not_nil(blank_error)
      assert_equal("can't be blank", blank_error)

      contact.name = "SOMETHING"
      assert_equal(true, contact.valid?)
      assert_equal(0, contact.errors.size)
    end
  end

  context "response parsing" do
    it "parses default attributes" do
      @instance = Xeroizer::Record::ContactModel.new(nil, "Contact")

      some_xml = get_record_xml("contact")

      result = @instance.parse_response(some_xml)
      contact = result.response_items.first

      keys = [:contact_id,
              :contact_status,
              :name,
              :first_name,
              :last_name,
              :email_address,
              :skype_user_name,
              :bank_account_details,
              :tax_number,
              :accounts_receivable_tax_type,
              :accounts_payable_tax_type,
              :addresses,
              :phones,
              :updated_date_utc,
              :is_supplier,
              :is_customer,
              :default_currency]

      assert_equal(contact.attributes.keys, keys)
    end

    should "be able to have no name if has a contact_id" do
      contact = @client.Contact.build

      assert_equal(false, contact.valid?)
      contact.contact_id = "1-2-3"
      assert_equal(true, contact.valid?)
      assert_equal(0, contact.errors.size)
    end

    it "parses extra attributes when present" do
      @instance = Xeroizer::Record::ContactModel.new(nil, "Contact")
      some_xml = get_record_xml("contact_with_details")

      result = @instance.parse_response(some_xml)
      contact = result.response_items.first

      keys = [:contact_id,
              :contact_status,
              :name,
              :first_name,
              :last_name,
              :email_address,
              :skype_user_name,
              :bank_account_details,
              :tax_number,
              :accounts_receivable_tax_type,
              :accounts_payable_tax_type,
              :addresses,
              :phones,
              :updated_date_utc,
              :is_supplier,
              :is_customer,
              :default_currency,
              :balances,
              :batch_payments,
              :payment_terms]

      assert_equal(contact.attributes.keys, keys)

      assert_equal(contact.balances.accounts_receivable.outstanding, 849.50)
      assert_equal(contact.balances.accounts_receivable.overdue, 910.00)
      assert_equal(contact.balances.accounts_payable.outstanding, 0.00)
      assert_equal(contact.balances.accounts_payable.overdue, 0.00)

      assert_equal(contact.batch_payments.bank_account_number, "123456")
      assert_equal(contact.batch_payments.bank_account_name, "bank account")
      assert_equal(contact.batch_payments.details, "details")

      assert_equal(contact.payment_terms.bills.day, "4")
      assert_equal(contact.payment_terms.bills.type, "OFFOLLOWINGMONTH")
      assert_equal(contact.payment_terms.sales.day, "2")
      assert_equal(contact.payment_terms.sales.type, "OFFOLLOWINGMONTH")
    end
  end
end
