module Xeroizer
  module Record
    module Payroll
    
      class PayrollCalendarModel < PayrollBaseModel
        # set_permissions :read, :write
        set_permissions :read
      end
      
      class PayrollCalendar < PayrollBase
        CALENDAR_TYPE = {
          'WEEKLY' => '',
          'FORTNIGHTLY' => '',
          'FOURWEEKLY' => '',
          'MONTHLY' => '',
          'TWICEMONTHLY' => '',
          'QUARTERLY' => ''
        } unless defined?(CALENDAR_TYPE)
        CALENDAR_TYPES = CALENDAR_TYPE.keys.sort
        
        set_primary_key :payroll_calendar_id

        guid        :payroll_calendar_id, :api_name => 'PayrollCalendarID'
        string      :name
        string      :calendar_type
        datetime    :start_date
        datetime    :payment_date

        validates_presence_of :payroll_calendar_id, :unless => :new_record?
        validates_presence_of :name
        validates_length_of :name, length: { maximum: 100 }, :allow_blanks => true
        validates_presence_of :calendar_type
        validates_inclusion_of :calendar_type, :in => CALENDAR_TYPES
        validates_presence_of :start_date
        validates_presence_of :payment_date
      end
    end
  end
end