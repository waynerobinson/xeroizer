require "test_helper"
require "pry"

class PayRunModelParsingTest < Test::Unit::TestCase
  def setup
    # See lib/xeroizer/record/base_model.rb
    @instance = Xeroizer::Record::Payroll::PayRunModel.new(nil, "PayRun")
  end

  must "parses attributes" do
    xml =
      "
      <Response>
        <PayRuns>
          <PayRun>
            <PayRunID>5fd08c46-6057-47d9-8f03-4f2153d2dea8</PayRunID>
            <PayScheduleID>d2ec5abc-2487-4d47-b9ac-bca09e1470bd</PayScheduleID>
            <PayRunPeriodStartDate>2014-03-01T00:00:00</PayRunPeriodStartDate>
            <PayRunPeriodEndDate>2014-03-07T00:00:00</PayRunPeriodEndDate>
            <PaymentDate>2014-03-09T00:00:00</PaymentDate>
            <Earnings>3096.23</Earnings>
            <Deductions>18.19</Deductions>
            <Tax>943.32</Tax>
            <Reimbursement>0.00</Reimbursement>
            <NetPay>2134.72</NetPay>
            <PayRunStatus>DRAFT</PayRunStatus>
            <UpdatedDateUTC>2014-03-25T05:33:51</UpdatedDateUTC>
          </PayRun>
        </PayRuns>
      </Response>
      "

      result = @instance.parse_response(xml)

      pay_run = result.response_items.first

      assert_equal pay_run.pay_run_id, "5fd08c46-6057-47d9-8f03-4f2153d2dea8"
      assert_equal pay_run.pay_schedule_id, "d2ec5abc-2487-4d47-b9ac-bca09e1470bd"
      assert_equal pay_run.pay_run_period_start_date, Date.parse("2014-03-01T00:00:00")
      assert_equal pay_run.pay_run_period_end_date, Date.parse("2014-03-07T00:00:00")
      assert_equal pay_run.payment_date, Date.parse("2014-03-09T00:00:00")
      assert_equal pay_run.earnings, BigDecimal("3096.23")
      assert_equal pay_run.deductions, BigDecimal("18.19")
      assert_equal pay_run.tax, BigDecimal("943.32")
      assert_equal pay_run.reimbursement, BigDecimal("0.0")
      assert_equal pay_run.net_pay, BigDecimal("2134.72")
      assert_equal pay_run.pay_run_status, 'DRAFT'
    end

end
