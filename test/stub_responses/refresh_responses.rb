require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'xeroizer')

client = Xeroizer::PrivateApplication.new(ARGV[0], ARGV[1], ARGV[2])

base_path = File.expand_path(File.dirname(__FILE__))

if ARGV[3]
  models = [ARGV[3]]
else
  models = %w(Account BrandingTheme Contact CreditNote Currency Employee Invoice Item ManualJournal Organisation Payment TaxRate TrackingCategory)
end

models.each do | model_name |
  model = client.send(model_name.to_sym)
  
  # List
  records = model.all
  File.open("#{base_path}/#{model_name.underscore.pluralize}.xml", "w") { | fp | fp.write model.response.response_xml }
  
  if %w(Contact CreditNote Invoice ManualJournal).include?(model_name)
    records.each do | summary_record |
      record = model.find(summary_record.id)
      File.open("#{base_path}/records/#{model_name.underscore}-#{record.id}.xml", "w") { | fp | fp.write model.response.response_xml }
    end    
    
    record = model.find(records.first.id)
    File.open("#{base_path}/#{model_name.underscore.singularize}.xml", "w") { | fp | fp.write model.response.response_xml }
  end
end