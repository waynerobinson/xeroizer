module Xeroizer
  class OAuth2

    attr_reader :client, :access_token

    attr_accessor :tenant_id

    def initialize(client_key, client_secret, options = {})
      @client = ::OAuth2::Client.new(client_key, client_secret, options)
    end

    def authorize_from_access(access_token, options = {})
      @access_token = ::OAuth2::AccessToken.new(client, access_token)
    end

    def get(path, headers = {})
      wrap_response(access_token.get(path, headers: wrap_headers(headers)))
    end

    def post(path, body = "", headers = {})
      wrap_response(access_token.post(path, {body: body, headers: wrap_headers(headers)}))
    end

    def put(path, body = "", headers = {})
      wrap_response(access_token.put(path, body: body, headers: wrap_headers(headers)))
    end

    def delete(path, headers = {})
      wrap_response(access_token.delete(path, headers: wrap_headers(headers)))
    end

    private

    def wrap_headers(headers)
      if tenant_id
        headers.merge("Xero-tenant-id" => tenant_id)
      else
        headers
      end
    end

    def wrap_response(response)
      Response.new(response)
    end

    class Response
      attr_reader :response

      def initialize(response)
        @response = response
      end

      def code
        response.status
      end

      def success?
        (200..299).to_a.include?(code)
      end

      def plain_body
        response.body
      end
    end
  end
end
