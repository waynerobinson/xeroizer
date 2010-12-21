require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'xeroizer')

client = Xeroizer::PrivateApplication.new('NDLINGM4YTGWMJYXNGVLZGFKN2M0ZG', 'YK1WI2S1QLWHCNTXA1KYO0DFEC7SC3', '/Users/waynerobinson/ac/apps/xero_keys/xeropk.pem')

base_path = File.expand_path(File.dirname(__FILE__))
%w(Account BrandingTheme Contact CreditNote Currency Invoice Organisation TaxRate TrackingCategory).each do | model_name |
  model = client.send(model_name.to_sym)
  
  # List
  records = model.all
  File.open("#{base_path}/#{model_name.underscore.pluralize}.xml", "w") { | fp | fp.write model.response.response_xml }
  
  if %w(Contact CreditNote Invoice).include?(model_name)
    records.each do | summary_record |
      record = model.find(summary_record.id)
      File.open("#{base_path}/records/#{model_name.underscore}-#{record.id}.xml", "w") { | fp | fp.write model.response.response_xml }
    end    
    
    record = model.find(records.first.id)
    File.open("#{base_path}/#{model_name.underscore.singularize}.xml", "w") { | fp | fp.write model.response.response_xml }
  end
end