require 'test_helper'

class PayRunsTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET).payroll
    mock_api('PayRuns')
  end

  test "get all" do
    runs = @client.PayRun.all
    assert_equal 2, runs.length
  end
end
