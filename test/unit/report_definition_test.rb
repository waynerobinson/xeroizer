require 'test_helper'

class ReportDefinitionTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
  end
  
  context "report definitions" do
    
    should "be defined correctly" do
      [ 
        :AgedPayablesByContact, :AgedReceivablesByContact, :BalanceSheet, :BankStatement, :BankSummary,
        :BudgetSummary, :ExecutiveSummary, :ProfitAndLoss, :TrialBalance
      ].each do | report_type |
        report_factory = @client.send(report_type)
        assert_kind_of(Xeroizer::Report::Factory, report_factory)
        assert_kind_of(Xeroizer::GenericApplication, report_factory.application)
        assert_equal(report_type.to_s, report_factory.report_type)
      end
    end
    
  end

end
