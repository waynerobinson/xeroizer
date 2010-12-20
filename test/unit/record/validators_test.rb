require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class ValidatorsTest < Test::Unit::TestCase
  include TestHelper
  
  class TestRecord < Xeroizer::Record::Base
    
    string  :name
    string  :name_conditional_if
    string  :name_conditional_unless
    string  :type
    string  :type_blank
    integer :value

    validates_presence_of :name, :message => "blank"
    validates_presence_of :name_conditional_if, :if => Proc.new { | record | record.value == 10 }, :message => "blank_if_10"
    validates_presence_of :name_conditional_unless, :unless => Proc.new { | record | record.value == 20 }, :message => "blank_unless_20"
    validates_inclusion_of :type, :in => %w(phone fax mobile), :message => "not_included"
    validates_inclusion_of :type_blank, :in => %w(phone fax mobile), :message => "not_included_blank", :allow_blank => true
  end
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @record = TestRecord.new(@client)
  end
  
  context "inclusion validator" do
    
    should "be included in list" do
      # Nil type
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:type).first
      assert_not_nil(error)
      assert_equal('not_included', error[1])
      
      # Invalid type
      @record.type = 'phone not valid'
      @record.valid?
      error = @record.errors_for(:type).first
      assert_not_nil(error)
      assert_equal('not_included', error[1])
      
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
      assert_equal('not_included_blank', error[1])
      
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
      assert_equal('blank', error[1])
      
      @record.name = "NOT BLANK"
      @record.valid?
      error = @record.errors_for(:name).first
      assert_nil(error)
    end
    
    should "have name if value is 10" do
      @record.value = 10
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:name_conditional_if).first
      assert_equal('blank_if_10', error[1])
      
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
    
    should "have name unless value is 20" do
      @record.value = 50
      assert_equal(false, @record.valid?)
      error = @record.errors_for(:name_conditional_unless).first
      assert_equal('blank_unless_20', error[1])
      
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
        
  end
  
end