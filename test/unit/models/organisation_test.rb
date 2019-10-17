require 'test_helper'

class OrganisationTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
  end

  context "sales_tax_basis_validations" do
    should "allow nil sales tax bases and countries" do
      organisation = @client.Organisation.build

      assert(organisation.valid?)
    end

    it 'should validate sales_tax_basis' do
      organisation = @client.Organisation.build(:sales_tax_basis => "Cat")

      assert(!organisation.valid?)

      organisation.sales_tax_basis = "ACCRUALS"

      assert(organisation.valid?)
    end

    it 'should validate sales_tax_basis for a specific country like NZ' do
      organisation = @client.Organisation.build(:sales_tax_basis => "FLATRATECASH", :country_code => "NZ")

      assert(!organisation.valid?)

      organisation.sales_tax_basis = "NONE"

      assert(organisation.valid?)
    end
  end

  context "parse response" do
    it "includes payment_terms" do
      @instance = Xeroizer::Record::OrganisationModel.new(nil, "Organisation")
      some_xml = get_record_xml("organisations")

      result = @instance.parse_response(some_xml)
      organisation = result.response_items.first

      assert_equal(organisation.payment_terms.bills.day, "4")
      assert_equal(organisation.payment_terms.bills.type, "OFFOLLOWINGMONTH")
      assert_equal(organisation.payment_terms.sales.day, "2")
      assert_equal(organisation.payment_terms.sales.type, "OFFOLLOWINGMONTH")
    end
  end
end
