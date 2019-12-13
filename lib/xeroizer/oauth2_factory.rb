module Xeroizer
   class OAuth2Factory
    def self.build(client_id, client_secret, options)
      OAuth2.new(client_id, client_secret, options)
    end
  end
end
