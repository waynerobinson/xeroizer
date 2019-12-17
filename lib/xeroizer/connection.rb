module Xeroizer
  class Connection
    def self.current_connections(client)
      JSON.parse(client.get('https://api.xero.com/connections').plain_body).map do |connection_json|
        new(connection_json)
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