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

# contact = gw.Contact.find('860B99A9-0958-4C8D-A98F-BB1F092B16BB')
# pp contact
# puts contact.contact_id
# puts contact.name
# puts contact.addresses.first.line1
# puts contact.phones[1].number
# 
# tax_rates = gw.TaxRate.all
# pp tax_rates

# journals = gw.Journal.all
# pp journals

# contacts = gw.Contact.all
# puts "Size: #{contacts.size}"
# puts "#{contacts.first.parent.class.name}"

# contact = gw.Contact.build({:name => "Test Company #{rand(1000000000)}", :first_name => "Wayne", :last_name => "Robinson"})
# contact.save
# # puts "New Record: #{contact.new_record?}"
# 
# contact.name = "Test Company Changed #{rand(1000000000)}"
# contact.save
# # puts contact.attributes.inspect
# puts "ID: #{contact.contact_id}"
# puts "Name: #{contact.name}"

# contact.add_address({:type => 'STREET', :line1 => '22 Lambert Drive', :city => "Maudsland", :region => 'QLD', :postal_code => '4210'}, {:type => 'POBOX', :line1 => '22 Lambert Drive', :city => "Maudsland", :region => 'QLD', :postal_code => '4210'})
# contact.addresses = [contact.build_address(:type => 'STREET', :line1 => '22 Lambert Drive', :city => "Maudsland", :region => 'QLD', :postal_code => '4210')]
# puts contact.to_xml

# puts "\n\n"
# 
# invoice = gw.Invoice.build({:type => 'ACCREC', :date => Time.now, :due_date => Time.now + (30 * 3600 * 24), :line_amount_types => 'Exclusive', :invoice_number => 'TEST001'})
# invoice.build_contact({:name => "Test Company", :first_name => "Wayne", :last_name => "Robinson"})
# invoice.add_line_item(:description => "Test line 1", :quantity => 2, :unit_amount => 50.50, :account_code => '100')
# puts invoice.to_xml


# response_xml = gw.http_get(gw.client, "#{gw.xero_url}/Invoice/a1d04a14-96a8-4067-a0ff-8136990a354f")
# 
# doc = Nokogiri::XML(response_xml)
# org = doc.xpath("/Response/Invoices/Invoice").last
# pp Hash.xml_node_to_hash(org)
# 

# credit_note = gw.CreditNote.find('371cd138-1e5c-4ec1-a8c6-a1c10e8bdab1')
# puts "Total: #{credit_note.total}"
# puts "LineItems: "
# credit_note.line_items.each_with_index do | line_item, index |
#   puts "\t#{index + 1}: #{line_item.description}: #{line_item.line_amount}"
# end
# 
# invoices = gw.Invoice.all
# puts "All invoices: #{invoices.size}"
# 
# after_date = Time.parse("2010-11-10 10:00:00")
# invoices = gw.Invoice.all(:where => "Date>=DateTime.parse(\"#{after_date.utc.strftime("%Y-%m-%dT%H:%M:%S")}\")")
# puts "Invoices after #{after_date}: #{invoices.size}"
# 
# 
# after_date = Time.parse("2010-11-30 10:00:00")
# invoices = gw.Invoice.all(:modified_since => after_date)
# puts "Invoices modified after #{after_date}: #{invoices.size}"
  
end_time = Time.now
puts "Completed in #{end_time - start_time} seconds."