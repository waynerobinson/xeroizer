require 'test_helper'

class EmployeesTest < Test::Unit::TestCase
  include TestHelper
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET).payroll
    mock_api('Employees')
  end

  test "get all" do
    employees = @client.Employee.all
    assert_equal 7, employees.length

    employee = @client.Employee.find(employees.first.id)
    assert_not_nil employee.home_address
    assert_equal 2, employee.bank_accounts.length
    assert_equal 1, employee.super_memberships.length

    assert_not_nil employee.pay_template
    assert_equal 1, employee.pay_template.earnings_lines.length

    assert_not_nil employee.opening_balances
    assert_not_nil employee.opening_balances.opening_balance_date
    assert_equal 1, employee.opening_balances.earnings_lines.length

    assert_not_nil employee.leave_balances
    assert_equal 2, employee.leave_balances.length
    assert_not_nil employee.leave_balances.first.leave_name
    assert_not_nil employee.leave_balances.first.leave_type_id
    assert_not_nil employee.leave_balances.first.number_of_units
    assert_not_nil employee.leave_balances.first.type_of_units
  end
end
