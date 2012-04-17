require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

class JournalLineTest < Test::Unit::TestCase
  include TestHelper
  include Xeroizer::Record
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
  end
  
  it "journal_line tracking specified correctly" do
    journal = @client.Journal.build
    journal_line = journal.add_journal_line({})
    
    journal_line.add_tracking_category(:name => "Name 1", :option => "Option 1")
    journal_line.add_tracking_category(:name => "Name 2", :option => "Option 2")
    
    doc = Nokogiri::XML(journal_line.to_xml)
    assert_equal 2, doc.xpath("/JournalLine/TrackingCategories/TrackingCategory").size
  end

end
