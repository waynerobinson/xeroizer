require "test_helper"

class PayScheduleModelParsingTest < Test::Unit::TestCase
  def setup
    @instance = Xeroizer::Record::Payroll::PayScheduleModel.new(nil, "PaySchedule")
  end

  must "parses attributes" do
    xml =
      "
      <Response>
        <PaySchedules>
          <PaySchedule>
            <PayScheduleID>3f29f8e1-e4aa-4d2b-a946-393b5269ef62</PayScheduleID>
            <PayScheduleName>Monthly</PayScheduleName>
            <ScheduleType>MONTHLY</ScheduleType>
            <StartDate>2014-03-01T00:00:00</StartDate>
            <PaymentDate>2014-03-24T00:00:00</PaymentDate>
            <UpdatedDateUTC>2014-02-13T00:58:06</UpdatedDateUTC>
          </PaySchedule>
        </PaySchedules>
      </Response>
      "

    result = @instance.parse_response(xml)

    pay_schedule = result.response_items.first

    assert_equal pay_schedule.pay_schedule_id, "3f29f8e1-e4aa-4d2b-a946-393b5269ef62"
    assert_equal pay_schedule.pay_schedule_name, "Monthly"
    assert_equal pay_schedule.schedule_type, "MONTHLY"
    assert_equal Date.parse("2014-03-01T00:00:00"), pay_schedule.start_date
    assert_equal Date.parse("2014-03-24T00:00:00"), pay_schedule.payment_date
    assert_equal Time.parse("2014-02-13T00:58:06Z"), pay_schedule.updated_date_utc
  end

  must "validate schedule type" do
    xml =
      "
      <Response>
        <PaySchedules>
          <PaySchedule>
            <PayScheduleID>3f29f8e1-e4aa-4d2b-a946-393b5269ef62</PayScheduleID>
            <PayScheduleName>Monthly</PayScheduleName>
            <ScheduleType>ABCD</ScheduleType>
            <StartDate>2014-03-01T00:00:00</StartDate>
            <PaymentDate>2014-03-24T00:00:00</PaymentDate>
            <UpdatedDateUTC>2014-02-13T00:58:06</UpdatedDateUTC>
          </PaySchedule>
        </PaySchedules>
      </Response>
      "

    result = @instance.parse_response(xml)

    pay_schedule = result.response_items.first

    assert_equal false, pay_schedule.valid?
    assert_equal 1, pay_schedule.errors.count
    assert_equal pay_schedule.errors[0], [:schedule_type, "not one of WEEKLY, MONTHLY, BIWEEKLY, QUARTERLY, SEMIMONTHLY, FOURWEEKLY, YEARLY"]
  end
end
