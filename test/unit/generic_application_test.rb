require 'test_helper'

class GenericApplicationTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @headers = {"User-Agent" => "Xeroizer/2.15.5"}
    @unitdp = 4
    @client = Xeroizer::GenericApplication.new(CONSUMER_KEY, CONSUMER_SECRET, :default_headers => @headers, :unitdp => @unitdp)
  end

  context "initialization" do

    should "pass default headers" do
      assert_equal(@headers, @client.default_headers)
    end

    should "pass unitdp value" do
      assert_equal(@unitdp, @client.unitdp)
    end

  end

end


