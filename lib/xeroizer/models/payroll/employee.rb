module Xeroizer
  module Record
    module Payroll

      class EmployeeModel < PayrollBaseModel

        set_permissions :read, :write, :update

        def create_method
          :http_post
        end
      end

      class Employee < PayrollBase

        def initialize(parent)
          super(parent)
          self.api_method_for_updating = :http_put if json?
        end

        set_primary_key :employee_id

        guid          :employee_id
        string        :status
        string        :title
        string        :first_name
        string        :middle_names
        string        :last_name
        date          :start_date
        string        :email
        date          :date_of_birth
        string        :gender
        string        :phone
        string        :phone_number
        string        :mobile
        string        :twitter_user_name
        boolean       :is_authorised_to_approve_leave
        boolean       :is_authorised_to_approve_timesheets
        string        :occupation
        string        :classification
        guid          :ordinary_earnings_rate_id
        guid          :payroll_calendar_id
        string        :employee_group_name
        date          :termination_date
        string        :national_insurance_number # UK
        guid          :pay_run_calendar_id # UK
        datetime_utc  :updated_date_utc, api_name: 'UpdatedDateUTC'
        date          :end_date, api_name: 'EndDate' # UK - null when employee is active

        belongs_to    :address, :internal_name_singular => "address", :model_name => "Address", api_name: 'address'
        belongs_to    :home_address, :internal_name_singular => "home_address", :model_name => "HomeAddress"
        belongs_to    :tax_declaration, :internal_name_singular => "tax_declaration", :model_name => "TaxDeclaration"
        has_many      :bank_accounts
        belongs_to    :pay_template, :internal_name_singular => "pay_template", :model_name => "PayTemplate"
        belongs_to    :opening_balances, :internal_name_singular => "opening_balance", :model_name => "OpeningBalances"
        has_many      :super_memberships, :internal_name_singular => "super_membership", :model_name => "SuperMembership"
        has_many      :leave_balances, :internal_name_singular => "leave_balance", model_name: "LeaveBalance"
        has_many      :leave_types, :internal_name_singular => "leave_type", model_name: "LeaveType"
        has_many      :time_off_balances, :internal_name_singular => "time_off_balance", model_name: "TimeOffBalance"

        def api_url
          json? ? "employees/#{employee_id}" : super
        end
      end

    end
  end
end
