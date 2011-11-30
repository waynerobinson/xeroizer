CredentialSet = Struct.new("CredentialSet", :consumer, :token)
Credential = Struct.new("Credential", :key, :secret)

Credential.class_eval do
  alias_method :token, :key
end

class Clock
  def timestamp; Time.now.to_i; end
  alias_method :nonce, :timestamp
end
