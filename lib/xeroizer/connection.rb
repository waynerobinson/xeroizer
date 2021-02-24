module Xeroizer
  class Connection
    attr_accessor :attributes
    attr_reader :parent

    class << self
      def current_connections(client)
        response = do_request(client)

        if response.success?
          JSON.parse(response.plain_body).map do |connection_json|
            build(connection_json, client)
          end
        else
          raise Xeroizer::OAuth::TokenInvalid, response.plain_body
        end
      end

      def build(attributes, parent)
        record = new(parent)
        record.attributes = attributes
        record
      end

      private

      def do_request(client)
        client.get('https://api.xero.com/connections')
      end
    end

    def initialize(parent)
      @parent = parent
      @attributes = {}
    end

    def method_missing(name, *_args)
      @attributes.send(:[], name.to_s.camelcase(:lower))
    end

    def delete
      parent.delete("https://api.xero.com/connections/#{id}")
    end

    def to_h
      attributes.transform_keys(&:underscore)
    end
  end
end
