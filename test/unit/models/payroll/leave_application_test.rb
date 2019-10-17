require 'test_helper'

class LeaveApplicationTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET).payroll
    #mock_api('Employees')
    #mock_api('LeaveApplications')
  end

=begin
  test "can get leave applications using employee ID" do
    application = @client.LeaveApplication.find(@client.Employee.first.id)
    assert_not_nil application
    assert_equal 1, application.leave_periods.size
    application.add_leave_periods(number_of_units: 48.00, pay_period_end_date: Date.today)
    application.save
    assert_equal 2, application.leave_periods.size
  end
=end
end
