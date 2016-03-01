require 'test_helper'

class ModelDefinitionsTest < Test::Unit::TestCase
  include TestHelper
  
  class FirstRecord < Xeroizer::Record::Base
    
    set_primary_key :primary_key_id
    
    guid      :primary_key_id
    string    :string1
    boolean   :boolean1
    integer   :integer1
    decimal   :decimal1
    date      :date1
    datetime  :datetime1
    
  end
  class Xeroizer::Record::FirstRecordModel < Xeroizer::Record::BaseModel; end
  
  class SecondRecord < Xeroizer::Record::Base

    set_primary_key :primary_key_id
    
    guid      :primary_key_id
    string    :string2
    boolean   :boolean2
    integer   :integer2
    decimal   :decimal2
    date      :date2
    datetime  :datetime2

  end
  class Xeroizer::Record::SecondRecordModel < Xeroizer::Record::BaseModel; end
    
  class TestRecord < Xeroizer::Record::Base
    
    string    :xml_name, :api_name => 'ApiNameHere', :internal_name => :internal_name_here
    string    :name
    
  end
  class Xeroizer::Record::TestRecordModel < Xeroizer::Record::BaseModel; end
  
  class SummaryOnlyRecord < Xeroizer::Record::Base
  class Xeroizer::Record::SummaryOnlyRecordModel < Xeroizer::Record::BaseModel; end
    
    list_contains_summary_only true
    set_possible_primary_keys :primary_key_id
    set_primary_key :primary_key_id
    
    string :primary_key_id
    string :name
  end
  
  class SummaryOnlyOffRecord < Xeroizer::Record::Base
  class Xeroizer::Record::SummaryOnlyOffRecordModel < Xeroizer::Record::BaseModel; end
    
    set_possible_primary_keys :primary_key_id
    set_primary_key :primary_key_id
    
    string :primary_key_id
    string :name
  end
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    parent = stub(:application => @client, :mark_dirty => nil)
    @first = FirstRecord.new(parent)
    @second = SecondRecord.new(parent)
    @record = TestRecord.build({}, @client.Contact)
    @contact = @client.Contact.build
  end
  
  context "list contains summary only test" do
    
    should "show download complete if not summary record and id set" do
      record = SummaryOnlyRecord.build({}, @client.Contact)
      record.id = "NOTBLANK"
      assert_equal(false, record.new_record?)
      assert_equal(false, record.complete_record_downloaded?)
      
      record = SummaryOnlyOffRecord.build({}, @client.Contact)
      record.id = "NOTBLANK"
      assert_equal(false, record.new_record?)
      assert_equal(true, record.complete_record_downloaded?)
    end
    
  end
  
  context "record field definition" do
    
    should "define primary key with real name" do
      assert_nil(@first.id)
      value = "PRIMARY KEY VALUE"
      @first.primary_key_id = value
      assert_equal(value, @first.primary_key_id)
      assert_equal(value, @first.id)
    end
    
    should "define primary key with shortcut #id method" do
      assert_nil(@first.id)
      value = "PRIMARY KEY VALUE"
      @first.id = value
      assert_equal(value, @first.id)
      assert_equal(value, @first.primary_key_id)
    end
    
    should "only have proper fields" do
      fieldset = [:primary_key_id, :string1, :boolean1, :integer1, :decimal1, :date1, :datetime1]
      fieldset.each do | field |
        assert(@first.class.fields.keys.include?(field), "#{field} not in FirstRecord.fields")
      end
      assert_equal(fieldset.size, @first.class.fields.size)

      fieldset = [:primary_key_id, :string2, :boolean2, :integer2, :decimal2, :date2, :datetime2]
      fieldset.each do | field |
        assert(@second.class.fields.keys.include?(field), "#{field} not in SecondRecord.fields")
      end
      assert_equal(fieldset.size, @second.class.fields.size)        
    end
    
    should "have correct names" do
      assert(@record.respond_to?(:internal_name_here), "Internal name should be internal_name_here")
      assert(@record.class.fields.keys.include?(:xml_name), "Field key name should be xml_name")
      assert_equal('ApiNameHere', @record.class.fields[:xml_name][:api_name])
    end
    
    should "have shortcut reader/writer" do 
      assert_nil(@first.string1)
      value = 'TEST VALUE'
      @first.string1 = value
      assert_equal(value, @first.attributes[:string1])
      assert_equal(value, @first[:string1])

      value = 'TEST VALUE 2'
      @first[:string1] = value
      assert_equal(value, @first.attributes[:string1])
    end
        
    should "define reader/writer methods" do
      assert(@record.respond_to?(:name), "FirstRecord#name should exist.")
      assert(@record.respond_to?(:name=), "FirstRecord#name= should exist.")
      
      value = "TEST NAME"
      @record.attributes[:name] = value
      assert_equal(value, @record.attributes[:name])
      assert_equal(value, @record[:name])
      assert_equal(value, @record.name)
      
      value = "TEST DIFFERENT"
      @record.name = value
      assert_equal(value, @record.attributes[:name])
      assert_equal(value, @record[:name])
      assert_equal(value, @record.name)
      
      value = "TEST DIFFERENT AGAIN"
      @record[:name] = value
      assert_equal(value, @record.attributes[:name])
      assert_equal(value, @record[:name])
      assert_equal(value, @record.name)
    end
    
  end
  
end
