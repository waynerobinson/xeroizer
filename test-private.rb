require 'lib/xeroizer.rb'
require 'pp'

start_time = Time.now

gw = Xeroizer::PrivateApplication.new('NDLINGM4YTGWMJYXNGVLZGFKN2M0ZG', 'YK1WI2S1QLWHCNTXA1KYO0DFEC7SC3', '/Users/waynerobinson/ac/apps/xero_keys/xeropk.pem')

# org = gw.Organisation.first
# puts org.inspect

# tracking_category = gw.TrackingCategory.first
# pp tracking_category
# 
# puts "Category name: #{tracking_category.name}"
# puts "Options:"
# pp tracking_category.options

contact = gw.Contact.find('860B99A9-0958-4C8D-A98F-BB1F092B16BB')
pp contact
puts contact.name
puts contact.addresses.first.address_line1
puts contact.phones[1].number

# response_xml = gw.http_get(gw.client, "#{gw.xero_url}/Invoice/a1d04a14-96a8-4067-a0ff-8136990a354f")
# 
# doc = Nokogiri::XML(response_xml)
# org = doc.xpath("/Response/Invoices/Invoice").last
# pp Hash.xml_node_to_hash(org)
# 
  
end_time = Time.now
puts "Completed in #{end_time - start_time} seconds."