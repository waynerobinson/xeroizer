require 'test_helper'

class OAuthTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
  end
  
  context "with oauth error handling" do
    
    should "handle token expired" do
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("token_expired"), :code => "401"))

      assert_raises Xeroizer::OAuth::TokenExpired do
        @client.Organisation.first
      end
    end
    
    should "handle invalid request tokens" do
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("invalid_request_token"), :code => "401"))
      
      assert_raises Xeroizer::OAuth::TokenInvalid do
        @client.Organisation.first
      end
    end
    
    should "handle invalid consumer key" do
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("invalid_consumer_key"), :code => "401"))
      
      assert_raises Xeroizer::OAuth::TokenInvalid do
        @client.Organisation.first
      end
    end

    should "handle nonce used" do
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("nonce_used"), :code => "401"))
      
      assert_raises Xeroizer::OAuth::NonceUsed do
        @client.Organisation.first
      end
    end

    should "raise rate limit exceeded" do
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("rate_limit_exceeded"), :code => "401"))
      
      assert_raises Xeroizer::OAuth::RateLimitExceeded do
        @client.Organisation.first
      end
    end

    should "automatically handle rate limit exceeded" do
      auto_rate_limit_client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET, :rate_limit_sleep => 1)

      # Return rate limit exceeded on first call, OK on the second
      Xeroizer::OAuth.any_instance.stubs(:get).returns(
        stub(:plain_body => get_file_as_string("rate_limit_exceeded"), :code => "401"),
        stub(:plain_body => get_record_xml(:organisation), :code => '200')
      )

      auto_rate_limit_client.expects(:sleep_for).with(1).returns(1)

      auto_rate_limit_client.Organisation.first
    end

    should "only retry rate limited request a configurable number of times" do
      auto_rate_limit_client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET, :rate_limit_sleep => 1, :rate_limit_max_attempts => 4)
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("rate_limit_exceeded"), :code => "401"))

      auto_rate_limit_client.expects(:sleep_for).with(1).times(4).returns(1)

      assert_raises Xeroizer::OAuth::RateLimitExceeded do
        auto_rate_limit_client.Organisation.first
      end
    end

    should "retry nonce_used failures a configurable number of times" do
      nonce_used_client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET, :nonce_used_max_attempts => 4)
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("nonce_used"), :code => "401"))

      nonce_used_client.expects(:sleep_for).with(1).times(4).returns(1)

      assert_raises Xeroizer::OAuth::NonceUsed do
        nonce_used_client.Organisation.first
      end
    end

    should "handle unknown errors" do
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("bogus_oauth_error"), :code => "401"))
      
      assert_raises Xeroizer::OAuth::UnknownError do
        @client.Organisation.first
      end
    end
    
    should "handle ApiExceptions" do
      Xeroizer::OAuth.any_instance.stubs(:put).returns(stub(:plain_body => get_file_as_string("api_exception.xml"),
          :code => "400"))
      
      assert_raises Xeroizer::ApiException do
        contact = @client.Contact.build(:name => 'Test Contact')
        contact.save
      end
    end
    
    should "handle random root elements" do
      Xeroizer::OAuth.any_instance.stubs(:put).returns(stub(:plain_body => "<RandomRootElement></RandomRootElement>",
          :code => "200"))
      
      assert_raises Xeroizer::UnparseableResponse do
        contact = @client.Contact.build(:name => 'Test Contact')
        contact.save
      end      
    end
    
  end
  
end
