require 'test_helper'

class ManualJournalTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    mock_api('ManualJournals')
  end

  context "paging" do
    should "have journal lines without downloading full manual journal when paging" do
      manual_journals = @client.ManualJournal.all(page: 1)

      manual_journals.each do |manual_journal|
        # This would kick off a full download without page param.
        manual_journal.journal_lines.size
        assert_equal(true, manual_journal.paged_record_downloaded?)

        # This indicates that there wasn't a separate download of the individual manual journal.
        assert_equal(false, manual_journal.complete_record_downloaded?)
      end
    end
  end
end