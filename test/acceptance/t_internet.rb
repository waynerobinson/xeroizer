require "request"

class TInternet
  def initialize(authorizer)
    @authorizer = authorizer
  end

  def get(url)
    request = Request.new(url, :get, nil, nil)

    authorized_request = @authorizer.authorize request

    try_get authorized_request
  end

  private

  def try_get(request)
    require 'rest_client'

    begin
      RestClient.get request.uri, request.headers do |response, request, result, &block|
        Response.new response.code.to_i, response.headers, response.body
      end
    rescue => e
      raise e unless e.respond_to?(:response)
      e.response
    end
  end
end
