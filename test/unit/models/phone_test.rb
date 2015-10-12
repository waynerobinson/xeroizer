require 'test_helper'

class PhoneTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @contact = @client.Contact.build

  end
  
  context "validators" do
    
    should "not allow long phone numbers" do
      @phone = @contact.add_phone(phone_number: "1234567890123456789012345678901234567890123456789012345678901234567890")
      assert_equal(false, @phone.valid?)
      blank_error = @phone.errors_for(:phone_number).first
      assert_not_nil(blank_error)
      assert_equal("must be shorter than 50 characters", blank_error)
      
    end

    should "allow phone numbers" do
      @phone = @contact.add_phone(phone_number: "12345690")

      assert_equal(true, @phone.valid?)
      assert_equal(0, @phone.errors.size)
    end
  end
  
end
