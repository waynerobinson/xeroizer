require 'test_helper'

class PrivateApplicationTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PrivateApplication.new(CONSUMER_KEY, CONSUMER_SECRET, PRIVATE_KEY_PATH)
  end
  
  context "initialization" do
    
    should "have a valid client" do
      assert_kind_of(Xeroizer::OAuth, @client.client)
      assert_equal(CONSUMER_KEY, @client.client.ctoken)
      assert_equal(CONSUMER_SECRET, @client.client.csecret)
    end
    
  end
    
end
