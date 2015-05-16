require 'xeroizer/models/external_link'

module Xeroizer
  module Record
    
    class EmployeeModel < BaseModel
        
      set_permissions :read, :write, :update
        
    end
    
    class Employee < Base
          
      set_primary_key :employee_id
            
      guid    :employee_id
      string  :status
      string  :first_name
      string  :last_name
      date    :date_of_birth

      # Optional attributes
      string  :gender # M or F
      string  :email
      string  :phone # (max length = 50, but AU only?)
      string  :mobile # (max length = 50)
      date    :start_date
      date    :termination_date
      boolean :is_authorised_to_approve_timesheets
      string  :employee_group_name

      datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      
      belongs_to  :external_link

      validates_presence_of :first_name, :last_name, :date_of_birth

    end

  #   # AU Only API
  #   class EmployeeAU < Employee
  #     string :occupation
  #     string :classification # length: 100
  #     string :ordinary_earnings_rate_id
  #     boolean :is_authorised_to_approve_leave

  #     string :title # (max length = 10)
  #     string :twitter_user_name # (max length = 50)
  #     # PayrollCalendarID Xero unique identifier for payroll calendar for the employee
  #     # BankAccounts  See BankAccount
  #     # SuperMemberships  See SuperMemberships
  #   end

  #   # US Only API
  #   class EmployeeUS < Employee
  #     string :middle_names #max length = 35
  #     string :job_title
  #     string :employee_number
  #     string :social_security_number # (xxx-xx-xxxx)
  #     string :holiday_group_id
  #     string :pay_schedule_id
  #     string :employment_basis  # One of http://developer.xero.com/documentation/payroll-api-us/Types-Codes/#EmploymentBasis
  #     boolean :is_authorised_to_approve_time_off

  #     # MailingAddress - US only, has_one relationship
  #     # SalaryAndWages  See SalaryAndWages
  #     # WorkLocations See WorkLocations
  #     # PaymentMethod See PaymentMethods
  #     # PayTemplate See PayTemplate
  #     # OpeningBalances See OpeningBalances
  #   end
  end
end
