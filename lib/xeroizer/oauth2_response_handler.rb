module Xeroizer
  class Oauth2ResponseHandler
    def self.from_response(response)
      Oauth2ResponseHandler.new(response)
    end

    def initialize(response)
      @response = response
    end

    def body
      case response.code.to_i
      when 200
        response.plain_body
      when 204
        nil
      when 400
        handle_error!(response)
      end
    end

    private

    attr_reader :response

    def handle_error!(response)
      raw_response = response.plain_body

      doc = Nokogiri::XML(raw_response)

      raise ApiException.new(doc.root.xpath("Type").text,
        doc.root.xpath("Message").text,
        raw_response,
        doc,
        "request_body")
    end
  end
end
