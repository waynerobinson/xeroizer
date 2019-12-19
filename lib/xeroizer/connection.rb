module Xeroizer
  class Connection
    class << self
      def current_connections(client)
        response = do_request(client)

        if response.success?
          JSON.parse(response.plain_body).map do |connection_json|
            new(connection_json)
          end
        else
          raise Xeroizer::OAuth::TokenInvalid, response.plain_body
        end
      end

      private

      def do_request(client)
        client.get('https://api.xero.com/connections')
      end
    end

    def initialize(json)
      @json = json
    end

    def method_missing(name, *_args)
      @json.send(:[], name.to_s.camelcase(:lower))
    end
  end
end
