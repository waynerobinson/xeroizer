require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class ModelDefinitionsTest < Test::Unit::TestCase
  include TestHelper
  
  class FirstRecord < Xeroizer::Record::Base
    
    string    :string1
    boolean   :boolean1
    integer   :integer1
    decimal   :decimal1
    date      :date1
    datetime  :datetime1
    
  end
  
  class SecondRecord < Xeroizer::Record::Base

    string    :string2
    boolean   :boolean2
    integer   :integer2
    decimal   :decimal2
    date      :date2
    datetime  :datetime2

  end
    
  class TestRecord < Xeroizer::Record::Base
    
    string    :xml_name, :api_name => 'ApiNameHere', :internal_name => :internal_name_here
    string    :name
    
  end
    
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @first = FirstRecord.new(@client)
    @second = SecondRecord.new(@client)
    @record = TestRecord.build({}, @client.Contact)
    @contact = @client.Contact.build
  end
  
  context "record field definition" do
    
    should "only have proper fields" do
      fieldset = [:string1, :boolean1, :integer1, :decimal1, :date1, :datetime1]
      fieldset.each do | field |
        assert(@first.class.fields.keys.include?(field), "#{field} not in FirstRecord.fields")
      end
      assert_equal(fieldset.size, @first.class.fields.size)

      fieldset = [:string2, :boolean2, :integer2, :decimal2, :date2, :datetime2]
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