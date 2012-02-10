require 'test_helper'

module Xeroizer
  module Record
    
    class WhereHashTestModel < BaseModel
    end
    
    class WhereHashTest < Base

      set_primary_key :primary_key_id

      guid      :primary_key_id
      string    :string1
      boolean   :boolean1
      integer   :integer1
      decimal   :decimal1
      date      :date1
      datetime  :datetime1

    end
  
  end
end  

class ParseWhereHashTest < Test::Unit::TestCase
  include TestHelper
    
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @model = Xeroizer::Record::WhereHashTestModel.new(@client, "WhereHashTest")
  end
  
  context "where hash" do
    
    should "parse valid hash" do
      @model.send(:parse_where_hash, {
        :primary_key_id => 'f7eca431-5c97-4d24-93fd-004bb8a6c644', 
        :string1 => 'test', 
        :boolean1 => true, 
        :integer1 => 10,
        :decimal1 => 123.45,
        :date1 => Date.parse("2010-01-05"),
        :datetime1 => Time.parse("2010-02-30 09:10:20")
      })
    end
    
    should 'have valid expression components' do
      assert_equal('String1=="abc"', CGI.unescape(@model.send(:parse_where_hash, {:string1 => 'abc'})))
      assert_equal('String1<>"abc"', CGI.unescape(@model.send(:parse_where_hash, {:string1_is_not => 'abc'})))
      assert_equal('String1<>"abc"', CGI.unescape(@model.send(:parse_where_hash, {:"string1<>" => 'abc'})))
      assert_equal('String1>"abc"', CGI.unescape(@model.send(:parse_where_hash, {:string1_is_greater_than => 'abc'})))
      assert_equal('String1>"abc"', CGI.unescape(@model.send(:parse_where_hash, {:"string1>" => 'abc'})))
      assert_equal('String1>="abc"', CGI.unescape(@model.send(:parse_where_hash, {:string1_is_greater_than_or_equal_to => 'abc'})))
      assert_equal('String1>="abc"', CGI.unescape(@model.send(:parse_where_hash, {:"string1>=" => 'abc'})))
      assert_equal('String1<"abc"', CGI.unescape(@model.send(:parse_where_hash, {:string1_is_less_than => 'abc'})))
      assert_equal('String1<"abc"', CGI.unescape(@model.send(:parse_where_hash, {:"string1<" => 'abc'})))
      assert_equal('String1<="abc"', CGI.unescape(@model.send(:parse_where_hash, {:string1_is_less_than_or_equal_to => 'abc'})))
      assert_equal('String1<="abc"', CGI.unescape(@model.send(:parse_where_hash, {:"string1<=" => 'abc'})))
    end
  end

end
