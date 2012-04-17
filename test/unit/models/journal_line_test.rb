require "test_helper"

class JournalLineTest < Test::Unit::TestCase
  include TestHelper
  include Xeroizer::Record
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
  end
  
  it "journal_line tracking specified correctly" do
    invoice = @client.Journal.build
    line = invoice.add_journal_line({})
    
    line.add_tracking_category(:name => "Name 1", :option => "Option 1")
    line.add_tracking_category(:name => "Name 2", :option => "Option 2")
    
    doc = Nokogiri::XML(line.to_xml)
    assert_equal 2, doc.xpath("/JournalLine/TrackingCategories/TrackingCategory").size
  end

end
