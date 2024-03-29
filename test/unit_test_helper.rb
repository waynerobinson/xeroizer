require 'test_helper'
require 'webmock'
require 'mocha/test_unit'

include WebMock::API
WebMock.disable_net_connect!(allow_localhost: true)

class UnitTestCase < Test::Unit::TestCase
  def setup
    WebMock.reset!
    WebMock.enable!
  end

  def teardown
    WebMock.disable!
  end
end
