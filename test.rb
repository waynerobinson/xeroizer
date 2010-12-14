require 'rubygems'
require 'forwardable'
require 'oauth'
require 'oauth/signature/rsa/sha1'
require 'lib/xeroizer/oauth'

client = Xeroizer::OAuth.new('M2M4ZTRHOWNIYTLINDJMMJHIZJEYNW', 'RX0ZVVCWDJR6HGX2JKHICHCKYZ21O5', {
  :site => 'https://api-partner.network.xero.com',
  :authorize_url => 'https://api.xero.com/oauth/Authorize',
  :private_key_file => '/Users/waynerobinson/ac/apps/xero_keys/xeropk.pem',
  :signature_method => 'RSA-SHA1',
  :ssl_client_cert => OpenSSL::X509::Certificate.new(File.read(File.join(File.dirname(__FILE__), 'certs', 'entrust-cert.pem'))),
  :ssl_client_key => OpenSSL::PKey::RSA.new(File.read(File.join(File.dirname(__FILE__), 'certs', 'entrust-private.pem')), 'xero')
})
# request_token = client.request_token(:oauth_callback => 'http://appcordion.com/oauth/callback')
request_token = client.request_token
puts "Authorise URL: #{request_token.authorize_url}"

puts "Enter the verification code from Xero?"
oauth_verifier = gets.chomp  

client.authorize_from_request(client.request_token.token, client.request_token.secret, :oauth_verifier => oauth_verifier)

puts "Access token: #{client.access_token.token}"
puts "Access token secret: #{client.access_token.secret}"
puts "Accesss token expires: #{client.expires_in}"
puts "Accesss token auth. expires: #{client.authorization_expires_in}"
puts "Accesss toekn session handle: #{client.session_handle}"