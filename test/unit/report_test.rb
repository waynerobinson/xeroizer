require 'test_helper'

class MockNonReportClassDefinition; end

class FactoryTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    mock_report_api("TrialBalance")
    @report = @client.TrialBalance.get
  end
  
  context "report factory" do
    
    should "have correct API-part of URL based on its type" do
      [ 
        :AgedPayablesByContact, :AgedReceivablesByContact, :BalanceSheet, :BankStatement, :BankSummary,
        :BudgetSummary, :ExecutiveSummary, :ProfitAndLoss, :TrialBalance
      ].each do | report_type |
        report_factory = @client.send(report_type)
        assert_equal("Reports/#{report_type}", report_factory.api_controller_name)
      end
    end
    
    should "build report model from XML" do
      assert_kind_of(Xeroizer::Report::Base, @report)
    end
    
    should "have all attributes in report summary" do
      assert_equal("TrialBalance", @report.id)
      assert_equal("TrialBalance", @report.type)
      assert_equal("Trial Balance", @report.name)
      assert_equal(['Trial Balance', 'Demo Company (AU)', 'As at 23 March 2011'], @report.titles)
      assert_equal(Date.parse('2011-03-23'), @report.date)
      assert_equal(Time.parse('2011-03-23T00:29:12.6021453Z'), @report.updated_at)
    end
    
    should "have valid rows" do
      assert_not_equal(0, @report.rows.size)
      @report.rows.each do | row |
        assert_kind_of(Xeroizer::Report::Row, row)
        assert(%w(Header Row SummaryRow Section).include?(row.type), "'#{row.type}' is not a valid row type.")
      end
    end
    
    should "have cells and no rows if not Section" do
      @report.rows.each do | row |
        if row.type != 'Section'
          assert_not_equal(0, row.cells.size)
          assert_equal(0, row.rows.size)
        end
      end
    end
    
    should "have rows and no cells if Section" do
      @report.rows.each do | row |
        if row.type == 'Section'
          assert_equal(0, row.cells.size)
          assert_not_equal(0, row.rows.size)
        end
      end
    end
    
    should "convert cells to BigDecimal where possible" do
      num_regex = /^[-]?\d+(\.\d+)?$/
      counter = 0
      @report.rows.each do | row |
        if row.row? || row.summary?
          row.cells.each do | cell |
            counter += 1 if cell.value.is_a?(BigDecimal) && cell.value > 0
          end
        elsif row.section?
          row.rows.each do | row |
            if row.row? || row.summary?
              row.cells.each do | cell | 
                counter += 1 if cell.value.is_a?(BigDecimal) && cell.value > 0
              end
            end
          end
        end
      end
      assert_not_equal(0, counter, "at least one converted number in the report should be greater than 0")
    end
    
    should "be at least one Section row with a title" do
      counter = 0
      @report.rows.each do | row |
        counter += 1 if row.section? && row.title.to_s != ''
      end
      assert_not_equal(0, counter, "at least one row with type 'Section' should have a title")
    end

    should "have working report type helpers" do
      @report.rows.each do | row |
        if row.type == 'Section'
          check_valid_report_type(row)
          row.rows.each do | row |
            check_valid_report_type(row)
          end
        else
          check_valid_report_type(row)
        end
      end
    end
    
    should "have valid header row" do
      assert_kind_of(Xeroizer::Report::HeaderRow, @report.header)
      assert_equal(['Account', 'Debit', 'Credit', 'YTD Debit', 'YTD Credit'], @report.header.cells.map { | c | c.value })
    end
    
    should "have sections" do
      assert_not_equal(0, @report.sections)
      @report.sections.each do | section |
        assert_kind_of(Xeroizer::Report::SectionRow, section)
      end
    end
    
    should "have summary" do
      assert_kind_of(Xeroizer::Report::SummaryRow, @report.summary)
      assert_equal(['Total', '33244.04', '33244.04', '80938.93', '80938.93'], @report.summary.cells.map { | c | c.value.to_s })
    end
    
    should "have summary on final section for trial balance (which has a blank title)" do
      section = @report.sections.last
      summary = section.rows.last
      assert_kind_of(Xeroizer::Report::SummaryRow, summary)
      assert_nil(section.title)
      assert_equal(['Total', '33244.04', '33244.04', '80938.93', '80938.93'], summary.cells.map { | c | c.value.to_s })
    end
    
  end

  context "report factory in the dirty real world" do

    should "not use inheritance to find report class" do
      report = Xeroizer::Report::Factory.new(@client, :MockNonReportClassDefinition).klass
      assert_equal(Xeroizer::Report::Base, report)
    end

  end

  private
  
    def check_valid_report_type(row)
      case row.type
        when 'Header'       then assert_equal(true, row.header?)
        when 'Row'          then assert_equal(true, row.row?)
        when 'SummaryRow'   then assert_equal(true, row.summary?)
        when 'Section'      then assert_equal(true, row.section?)
        else
            assert(false, "Invalid type: #{row.type}")
      end
    end
    
end
