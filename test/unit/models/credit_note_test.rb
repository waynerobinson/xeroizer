require File.join(File.dirname(__FILE__), '../../test_helper.rb')

class CreditNoteTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @credit_note = @client.CreditNote.build
    @credit_note.add_line_item(:description => "First Line", :quantity => 1, :unit_amount => 10, :account_code => '100', :tax_amount => 10, :tax_type => 'OUTPUT')
    @credit_note.add_line_item(:description => "Second Line", :quantity => 2, :unit_amount => 20, :account_code => '100', :tax_amount => 20, :tax_type => 'OUTPUT')
  end
  
  context "credit note totals" do
    
    should "raise error when trying to set totals directly" do
      assert_raises Xeroizer::SettingTotalDirectlyNotSupported do
        @credit_note.sub_total = 100.0
      end
      assert_raises Xeroizer::SettingTotalDirectlyNotSupported do
        @credit_note.total_tax = 100.0
      end
      assert_raises Xeroizer::SettingTotalDirectlyNotSupported do
        @credit_note.total = 100.0
      end
    end
    
    should "total up amounts correctly" do
      assert_equal(50, @credit_note.sub_total)
      assert_equal(30, @credit_note.total_tax)
      assert_equal(80, @credit_note.total)
    end
    
    should "large-scale testing from API XML" do
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_file_as_string("credit_notes.xml"), :code => "200"))
      credit_notes = @client.CreditNote.all
      credit_notes.each do | credit_note |
        assert_equal(credit_note.attributes[:sub_total], credit_note.sub_total)
        assert_equal(credit_note.attributes[:total_tax], credit_note.total_tax)
        assert_equal(credit_note.attributes[:total], credit_note.total)
      end
    end
    
  end
  
end