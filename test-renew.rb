require 'lib/xeroizer.rb'

client = Xeroizer::OAuth.new('M2M4ZTRHOWNIYTLINDJMMJHIZJEYNW', 'RX0ZVVCWDJR6HGX2JKHICHCKYZ21O5', {
  :site => 'https://api-partner.network.xero.com',
  :authorize_url => 'https://api.xero.com/oauth/Authorize',
  :private_key_file => '/Users/waynerobinson/ac/apps/xero_keys/xeropk.pem',
  :signature_method => 'RSA-SHA1',
  :ssl_client_cert => OpenSSL::X509::Certificate.new(File.read(File.join(File.dirname(__FILE__), 'certs', 'entrust-cert.pem'))),
  :ssl_client_key => OpenSSL::PKey::RSA.new(File.read(File.join(File.dirname(__FILE__), 'certs', 'entrust-private.pem')), 'xero')
})

request_token = client.request_token
token = OAuth::Token.new(ARGV[0], ARGV[1])
access_token = request_token.get_access_token(:oauth_session_handle => ARGV[2], :token => token)

puts access_token.inspect