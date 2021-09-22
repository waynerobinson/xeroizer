require 'unit_test_helper'

class JournalLineTest < Test::Unit::TestCase
  include TestHelper
  include Xeroizer::Record

  def setup
    @client = Xeroizer::OAuth2Application.new(CLIENT_ID, CLIENT_SECRET)
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
