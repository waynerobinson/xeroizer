require 'test_helper'

class PayrollCalendarTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET).payroll
    mock_api('PayrollCalendars')
  end

  test "get all" do
    calendars = @client.PayrollCalendar.all
    assert_equal 3, calendars.size
  end

  test "get one" do
    calendar = @client.PayrollCalendar.first
    assert_not_nil calendar

    doc = Nokogiri::XML calendar.to_xml
    assert_equal 1, doc.xpath("/PayrollCalendar/PayrollCalendarID").size
  end
end
