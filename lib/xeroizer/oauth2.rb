module Xeroizer
  class OAuth2

    attr_reader :client, :access_token

    def initialize(client_key, client_secret, options = {})
      @client = ::OAuth2::Client.new(client_key, client_secret, options)
    end

    def authorize_from_access(access_token, options = {})
      @access_token = ::OAuth2::AccessToken.new(client, access_token)
    end

    def get(path, headers = {})
      wrap_response(access_token.get(path, headers: headers))
    end

    def post(path, body = "", headers = {})
      wrap_response(access_token.post(path, {body: body, headers: headers}))
    end

    def put(path, body = "", headers = {})
      wrap_response(access_token.put(uri, body: body, headers: headers))
    end

    def delete(path, headers = {})
      wrap_response(access_token.delete(uri, headers: headers))
    end

    private

    def wrap_response(response)
      Response.new(response)
    end

    def set_headers(req, headers)
      puts headers
      headers.each do |key, value|
        req.headers[key] = value
      end
    end

    class Response
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def code
        response.status
      end

      def plain_body
        response.body
      end
    end
  end
end
