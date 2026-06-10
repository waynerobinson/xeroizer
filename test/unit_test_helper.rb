require 'test_helper'
require 'webmock'

include WebMock::API

WebMock.disable_net_connect!(allow_localhost: true)

class UnitTestCase < Minitest::Test
  def setup
    WebMock.reset!
    WebMock.enable!
  end

  def teardown
    WebMock.disable!
  end
end
