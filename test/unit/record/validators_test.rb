require 'test_helper'

class ValidatorsTest < Test::Unit::TestCase
  include TestHelper
  
  class Xeroizer::Record::TestModel < Xeroizer::Record::BaseModel
  end
  
  class Xeroizer::Record::Test < Xeroizer::Record::Base
    
    string  :name
    string  :name_conditional_if
    string  :name_conditional_unless
    string  :name_conditional_method_if
    string  :name_conditional_method_unless
    string  :type
    string  :type_blank
    integer :value
    
    belongs_to :contact
    has_many :addresses

    validates_presence_of :name, :message => "blank"
    validates_presence_of :name_conditional_if, :if => Proc.new { | record | record.value == 10 }, :message => "blank_if_10"
    validates_presence_of :name_conditional_unless, :unless => Proc.new { | record | record.value == 20 }, :message => "blank_unless_20"
    validates_presence_of :name_conditional_method_if, :if => :value_equals_ten?, :message => "blank_if_10"
    validates_presence_of :name_conditional_method_unless, :unless => :value_equals_twenty?, :message => "blank_unless_20"
    validates_inclusion_of :type, :in => %w(phone fax mobile), :message => "not_included"
    validates_inclusion_of :type_blank, :in => %w(phone fax mobile), :message => "not_included_blank", :allow_blanks => true
    validates_associated :contact, :message => "association_invalid"
    validates_associated :addresses, :message => "association_invalid_blank", :allow_blanks => true
    
    def value_equals_ten?
      value == 10
    end
    
    def value_equals_twenty?
      value == 20
    end
  end
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @record = Xeroizer::Record::TestModel.new(@client, 'Test').build
  end
  
  context "associated validator" do
    
    should "exist and be valid" do
      # Nil contact
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:contact).first
      assert_not_nil(error)
      assert_equal('association_invalid', error)
      
      # Valid contact
      @record.build_contact({:name => 'VALID NAME'})
      @record.valid?
      error = @record.errors_for(:contact).first
      assert_nil(error)
    end
    
    should "exist and be valid unless allowed to be blank" do
      # Nil address
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:addresses).first
      assert_nil(error)
      
      # Valid address
      @record.add_address(:type => 'STREET')
      @record.valid?
      error = @record.errors_for(:addresses).first
      assert_nil(error)
      
      # Invalid address
      @record.addresses[0].type = "INVALID TYPE"
      @record.valid?
      error = @record.errors_for(:addresses).first
      assert_equal('association_invalid_blank', error)
      
      # One invalid address
      @record.add_address(:type => 'STREET')
      assert_equal(2, @record.addresses.size)
      @record.valid?
      error = @record.errors_for(:addresses).first
      assert_equal('association_invalid_blank', error)      
    end
    
  end
  
  context "inclusion validator" do
    
    should "be included in list" do
      # Nil type
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:type).first
      assert_not_nil(error)
      assert_equal('not_included', error)
      
      # Invalid type
      @record.type = 'phone not valid'
      @record.valid?
      error = @record.errors_for(:type).first
      assert_not_nil(error)
      assert_equal('not_included', error)
      
      # Valid type
      %w(phone fax mobile).each do | valid_type |
        @record.type = valid_type
        @record.valid?
        error = @record.errors_for(:type).first
        assert_nil(error)
      end
    end
    
    should "be included in list unless allowed to be blank" do
      # Nil type_blank
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:type_blank).first
      assert_nil(error)
      
      # Invalid type_blank
      @record.type_blank = 'phone not valid'
      @record.valid?
      error = @record.errors_for(:type_blank).first
      assert_not_nil(error)
      assert_equal('not_included_blank', error)
      
      # Valid type_blank
      %w(phone fax mobile).each do | valid_type |
        @record.type_blank = valid_type
        @record.valid?
        error = @record.errors_for(:type_blank).first
        assert_nil(error)
      end
    end
    
  end
  
  context "presence validator" do
    
    should "have name" do
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:name).first
      assert_not_nil(error)
      assert_equal('blank', error)
      
      @record.name = "NOT BLANK"
      @record.valid?
      error = @record.errors_for(:name).first
      assert_nil(error)
    end
    
    should "have name if value is 10" do
      @record.value = 10
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:name_conditional_if).first
      assert_equal('blank_if_10', error)
      
      @record.name_conditional_if = "NOT BLANK"
      @record.valid?
      error = @record.errors_for(:name_conditional_if).first
      assert_nil(error)
            
      @record.name_conditional_if = nil
      @record.value = 50
      @record.valid?
      error = @record.errors_for(:name_conditional_if).first
      assert_nil(error)
    end
    
    should "have name if value_equals_ten?" do
      @record.value = 10
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:name_conditional_method_if).first
      assert_equal('blank_if_10', error)
      
      @record.name_conditional_method_if = "NOT BLANK"
      @record.valid?
      error = @record.errors_for(:name_conditional_method_if).first
      assert_nil(error)
            
      @record.name_conditional_method_if = nil
      @record.value = 50
      @record.valid?
      error = @record.errors_for(:name_conditional_method_if).first
      assert_nil(error)
    end
    
    should "have name unless value is 20" do
      @record.value = 50
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:name_conditional_unless).first
      assert_equal('blank_unless_20', error)
      
      @record.name_conditional_unless = "NOT BLANK"
      @record.valid?
      error = @record.errors_for(:name_conditional_unless).first
      assert_nil(error)
            
      @record.name_conditional_unless = nil
      @record.value = 20
      @record.valid?
      error = @record.errors_for(:name_conditional_unless).first
      assert_nil(error)
    end
    
    should "have name unless value_equals_twenty?" do
      @record.value = 50
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:name_conditional_method_unless).first
      assert_equal('blank_unless_20', error)
      
      @record.name_conditional_method_unless = "NOT BLANK"
      @record.valid?
      error = @record.errors_for(:name_conditional_method_unless).first
      assert_nil(error)
            
      @record.name_conditional_method_unless = nil
      @record.value = 20
      @record.valid?
      error = @record.errors_for(:name_conditional_method_unless).first
      assert_nil(error)
    end
    
  end
  
end
