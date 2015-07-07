require 'test_helper'

class PhoneTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @phone = @client.Phone.build
  end
  
  context "validators" do
    
      validates_length_of :phone, :max => 50

    should "not allow long phone numbers" do
      @phone.phone_number = "1234567890123456789012345678901234567890123456789012345678901234567890"
      assert_equal(false, @phone.valid?)
      blank_error = @phone.errors_for(:phone_number).first
      assert_not_nil(blank_error)
      assert_equal("can't be blank", blank_error)
      
      @phone.phone_number = "1234567890"

      assert_equal(true, @phone.valid?)
      assert_equal(0, @phone.errors.size)
    end
  end
  
end
