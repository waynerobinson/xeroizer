require 'test_helper'

class RecordDefinitionTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
  end
  
  context "record definitions" do
    
    should "be defined correctly" do
      [ 
        :Account, :BrandingTheme, :Contact, :CreditNote, :Currency, :Invoice,
        :Item, :Journal, :ManualJournal, :Organisation, :Payment, :TaxRate,
        :TrackingCategory, :User
      ].each do | record_type |
        record_factory = @client.send(record_type)
        assert_kind_of(Xeroizer::Record::BaseModel, record_factory)
        assert_kind_of(Xeroizer::GenericApplication, record_factory.application)
        assert_equal(record_type.to_s, record_factory.model_name)
      end
    end
    
  end

end
