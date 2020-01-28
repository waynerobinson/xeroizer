require 'unit_test_helper'

class Oauth2ResponseHandlerTest < Test::Unit::TestCase
  include TestHelper

  should "return the plain body when the status code is 200" do
    response = OpenStruct.new(code: 200, plain_body: "this is the plain body")

    result = Xeroizer::Oauth2ResponseHandler.from_response(response).body
    assert_equal(response.plain_body, result)
  end

  should "return nil when the status code is 204" do
    response = OpenStruct.new(code: 204, plain_body: "this is the plain body")

    result = Xeroizer::Oauth2ResponseHandler.from_response(response).body
    assert_equal(nil, result)
  end

  should "raise API Exception when a bad request is made" do
    message = 'this is a message'
    type = 'custom_type'
    error_number = 17
    response = OpenStruct.new(code: 400, plain_body: "<ApiException
      xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"
      xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">
      <ErrorNumber>#{error_number}</ErrorNumber>
      <Type>#{type}</Type>
      <Message>#{message}</Message>
    </ApiException>")

    error = assert_raises Xeroizer::ApiException do
      Xeroizer::Oauth2ResponseHandler.from_response(response).body
    end

    assert_equal(message, error.instance_variable_get(:@message))
    assert_equal(type, error.instance_variable_get(:@type))
  end
end
