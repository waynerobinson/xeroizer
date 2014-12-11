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
            <Paystubs>
              <Paystub>
                <EmployeeID>7b15677d-b93c-4546-84aa-34395aeaffd6</EmployeeID>
                <PaystubID>fe8ea0be-1ea9-4fa6-9c18-18cd41c57de6</PaystubID>
                <FirstName>Payrun</FirstName>
                <LastName>Post</LastName>
                <LastEdited>2014-03-25T05:33:51</LastEdited>
                <Earnings>1577.00</Earnings>
                <Deductions>0.00</Deductions>
                <Tax>542.24</Tax>
                <Reimbursements>0.00</Reimbursements>
                <NetPay>1034.76</NetPay>
                <UpdatedDateUTC>2014-03-25T05:33:51</UpdatedDateUTC>
              </Paystub>
              <Paystub>
                <EmployeeID>de5d4e8c-ae2b-40aa-91cb-8eabd75c9ed5</EmployeeID>
                <PaystubID>8bb36b8b-3835-4680-8647-269f1172679e</PaystubID>
                <FirstName>what</FirstName>
                <LastName>what</LastName>
                <Earnings>1519.23</Earnings>
                <Deductions>18.19</Deductions>
                <Tax>401.08</Tax>
                <Reimbursements>0.00</Reimbursements>
                <NetPay>1099.96</NetPay>
                <UpdatedDateUTC>2014-03-25T05:33:51</UpdatedDateUTC>
              </Paystub>
            </Paystubs>
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

      assert_equal pay_run.paystubs.length, 2

      first_paystub = pay_run.paystubs[0]
      assert_equal first_paystub.employee_id, "7b15677d-b93c-4546-84aa-34395aeaffd6"
      assert_equal first_paystub.paystub_id, "fe8ea0be-1ea9-4fa6-9c18-18cd41c57de6"
      assert_equal first_paystub.first_name, "Payrun"
      assert_equal first_paystub.last_name, "Post"
      assert_equal first_paystub.last_edited, DateTime.parse("2014-03-25T05:33:51")
      assert_equal first_paystub.earnings, BigDecimal("1577.00")
      assert_equal first_paystub.deductions, BigDecimal("0.00")
      assert_equal first_paystub.tax, BigDecimal("542.24")
      assert_equal first_paystub.reimbursements, BigDecimal("0.00")
      assert_equal first_paystub.net_pay, BigDecimal("1034.76")
      assert_equal first_paystub.updated_date_utc, DateTime.parse("2014-03-25T05:33:51")
    end

end
