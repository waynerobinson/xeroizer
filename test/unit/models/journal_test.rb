require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

class JournalTest < Test::Unit::TestCase
  include TestHelper
  include Xeroizer::Record
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)

    @journal = @client.Journal.build
    @journal.journal_id = "0d926df3-459f-4264-a3a3-49ac065eb0ed"
    @journal.date = DateTime.strptime("2015-01-01T00:00:00Z")
    @journal.created_date_utc = DateTime.strptime("2015-01-01T00:00:00Z")
    @journal.journal_number = "JOURNAL_NUMBER"
    @journal.reference = "Web"
    @journal.source_id = "GUID"
    @journal.source_type = "Fish"

    @journal_line = @journal.add_journal_line({})

    @doc = Nokogiri::XML(@journal.to_xml)
  end

  context "rendering" do

    it "should render journal_lines" do
      assert_equal 1, @doc.xpath("//JournalLine").size
    end

    it "should render source_type, source_id" do
      assert_equal "GUID", @doc.xpath("//SourceID").text
      assert_equal "Fish", @doc.xpath("//SourceType").text
    end

    it "should render reference" do
      assert_equal "Web", @doc.xpath("//Reference").text
    end

    it "should render date" do
      assert_equal "2015-01-01", @doc.xpath("//JournalDate").text
    end
  end 

end
