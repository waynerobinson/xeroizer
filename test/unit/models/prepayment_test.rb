require 'unit_test_helper'

class PrepaymentTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::OAuth2Application.new(CLIENT_ID, CLIENT_SECRET)
    mock_api("Prepayments")
    @prepayment = @client.Prepayment.first
  end

  context "prepayment attributes" do
    should "large-scale testing from API XML" do
      prepayments = @client.Prepayment.all
      prepayments.each do | prepayment |
        assert_equal(prepayment.attributes[:prepayment_id], prepayment.prepayment_id)
        assert_equal(prepayment.attributes[:contact][:contact_id], prepayment.contact_id)
      end
    end
  end
end
