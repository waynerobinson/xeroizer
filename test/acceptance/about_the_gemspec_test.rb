require "test_helper"
require "acceptance_test"

class AboutCreatingBankTransactions < Test::Unit::TestCase
  include AcceptanceTest
  
  can "build the gem without error" do
    result = %x{ bundle exec gem build xeroizer.gemspec }
    assert_equal 0, $?.exitstatus, "Expected the gem to build okay"
  end
end
