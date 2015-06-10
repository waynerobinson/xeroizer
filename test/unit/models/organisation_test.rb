require 'test_helper'

class OrganisationTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    mock_api('Invoices')
  end

  def build_valid_organisation
    @client.Organisation.build({

    })

  end

  context "sales_tax_basis_validations" do
    should "allow nil sales tax bases and countries" do
      organisation = @client.Organisation.build
      assert(organisation.valid?)
    end
  end
end
