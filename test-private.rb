require 'lib/xeroizer.rb'
require 'pp'

start_time = Time.now

client = Xeroizer::OAuth.new('NDLINGM4YTGWMJYXNGVLZGFKN2M0ZG', 'YK1WI2S1QLWHCNTXA1KYO0DFEC7SC3', {
  :private_key_file => '/Users/waynerobinson/ac/apps/xero_keys/xeropk.pem',
  :signature_method => 'RSA-SHA1',
})

client.authorize_from_access('NDLINGM4YTGWMJYXNGVLZGFKN2M0ZG', 'YK1WI2S1QLWHCNTXA1KYO0DFEC7SC3')

class Gateway
  
  include Xeroizer::Http
  
  attr_reader :logger, :client
  
  def initialize(client)
    @client = client
  end

  def xero_url 
    "https://api.xero.com/api.xro/2.0"
  end
  
  def run
    response_xml = http_get(@client, "#{xero_url}/Invoice/a1d04a14-96a8-4067-a0ff-8136990a354f")
    
    doc = Nokogiri::XML(response_xml)
    org = doc.xpath("/Response/Invoices/Invoice").last
    pp Hash.xml_node_to_hash(org)
  end

end

gw = Gateway.new(client)
gw.run
  
end_time = Time.now
puts "Completed in #{end_time - start_time} seconds."