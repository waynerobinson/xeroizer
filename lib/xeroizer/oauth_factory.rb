module Xeroizer
   class OAuthFactory
    def self.build(consumer_key, consumer_secret, options)
      OAuth.new(consumer_key, consumer_secret, options)
    end
  end
end
