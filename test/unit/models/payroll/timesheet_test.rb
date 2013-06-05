require 'test_helper'

class TimesheetTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET).payroll
    mock_api('Employees')
    mock_api('Timesheets')
    @employee = @client.Employee.first
  end

  test "get all" do
    timesheets = @client.Timesheet.all
    assert_equal 2, timesheets.count
    timesheets.each do |timesheet|
      timesheet.timesheet_lines.each do |line|
        assert_equal 7, line.number_of_units.count
        line.number_of_units.each do |unit|
          assert_not_nil unit.value
        end
      end
    end
  end

  test "get one" do
    timesheet = @client.Timesheet.first
    assert_equal 2, timesheet.timesheet_lines.count
    assert_equal 7, timesheet.timesheet_lines.sample.number_of_units.count
  end

  test "create invalid timesheet" do
    timesheet = @client.Timesheet.build
    assert_equal(false, timesheet.valid?)
  end

  test "create valid timesheet" do
    timesheet = @client.Timesheet.build(employee_id: @employee.id, start_date: Date.today - 1.week, end_date: Date.today)
    assert_equal(true, timesheet.valid?)
  end

  test "create timesheet with units" do
    timesheet = @client.Timesheet.build(status: 'DRAFT', employee_id: @employee.id, start_date: Date.today - 1.week, end_date: Date.today)

    timesheet_line = timesheet.add_timesheet_line(earnings_rate_id: @employee.ordinary_earnings_rate_id)
    timesheet_line.add_to_number_of_units([8.00, 8.00, 8.00, 8.00, 8.00, 0.00, 0.00])

    doc = Nokogiri::XML timesheet.to_xml
    assert_equal 1, doc.xpath("/Timesheet/TimesheetLines/TimesheetLine").size
    assert_equal 7, doc.xpath("/Timesheet/TimesheetLines/TimesheetLine/NumberOfUnits/NumberOfUnit").size
  end
  
end
