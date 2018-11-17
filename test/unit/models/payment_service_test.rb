require 'test_helper'

class PaymentServiceTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
  end

  context "response parsing" do
    it "parses default attributes" do
      @instance = Xeroizer::Record::PaymentServiceModel.new(nil, "PaymentService")

      some_xml = get_record_xml("payment_service")

      result = @instance.parse_response(some_xml)
      payment_service = result.response_items.first

      keys = [:payment_service_id,
              :payment_service_name,
              :payment_service_type,
              :payment_service_url,
              :pay_now_text
      ]

      assert_equal(payment_service.attributes.keys, keys)
    end
  end
end
