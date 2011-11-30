require 'test_helper'

class CreditNoteTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)    
    mock_api("CreditNotes")
    @credit_note = @client.CreditNote.first
  end
  
  context "credit note totals" do
    
    should "raise error when trying to set totals directly" do
      assert_raises Xeroizer::SettingTotalDirectlyNotSupported do
        @credit_note.sub_total = 500.0
      end
      assert_raises Xeroizer::SettingTotalDirectlyNotSupported do
        @credit_note.total_tax = 50.0
      end
      assert_raises Xeroizer::SettingTotalDirectlyNotSupported do
        @credit_note.total = 550.0
      end
    end
        
    should "large-scale testing from API XML" do
      credit_notes = @client.CreditNote.all
      credit_notes.each do | credit_note |
        assert_equal(credit_note.attributes[:sub_total], credit_note.sub_total)
        assert_equal(credit_note.attributes[:total_tax], credit_note.total_tax)
        assert_equal(credit_note.attributes[:total], credit_note.total)
      end
    end
    
  end
  
end
