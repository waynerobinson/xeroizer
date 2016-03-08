require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'test_helper'))

class EmployeeTest < Test::Unit::TestCase
  include TestHelper
  include Xeroizer::Record
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @employee = @client.Employee.build

    @employee.employee_id = 'GUID'
    @employee.status = 'ACTIVE'

    @employee.first_name = 'Example'
    @employee.last_name = 'User'

    @employee.date_of_birth = DateTime.strptime("2015-01-01T00:00:00Z")

    @employee.gender = 'F'
    @employee.email = 'user@example.com'

    @employee.start_date = DateTime.strptime("2015-01-02T00:00:00Z")
    @employee.termination_date = DateTime.strptime("2015-01-03T00:00:00Z")
    @employee.is_authorised_to_approve_timesheets = false
    @employee.employee_group_name = "TEAM A"
    @doc = Nokogiri::XML(@employee.to_xml)
  end
  
  it "should render" do
    assert_equal "GUID", @doc.xpath("//EmployeeID").text
    assert_equal "ACTIVE", @doc.xpath("//Status").text
    assert_equal "Example", @doc.xpath("//FirstName").text
    assert_equal "User", @doc.xpath("//LastName").text
    assert_equal "2015-01-01", @doc.xpath("//DateOfBirth").text
    assert_equal "2015-01-02", @doc.xpath("//StartDate").text
    assert_equal "2015-01-03", @doc.xpath("//TerminationDate").text
    assert_equal "F", @doc.xpath("//Gender").text
    assert_equal "user@example.com", @doc.xpath("//Email").text

    assert_equal "false", @doc.xpath("//IsAuthorisedToApproveTimesheets").text
    assert_equal "TEAM A", @doc.xpath("//EmployeeGroupName").text
  end
end
