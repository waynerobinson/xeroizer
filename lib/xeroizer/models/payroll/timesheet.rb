module Xeroizer
  module Record
    module Payroll

      class TimesheetModel < PayrollBaseModel
        set_optional_xml_root_name 'Timesheets'
        set_permissions :read, :write, :update

      end

      class Timesheet < PayrollBase

        TIMESHEET_STATUS_CODES = [
          'Draft',
          'Processed',
          'Approved'
        ]unless defined?(TIMESHEET_STATUS_CODES)


        set_primary_key :tilesheet_id

        guid          :tilesheet_id, :api_name => 'TimesheetID'
        guid          :employee_id
        string        :status
        date          :start_date # YYYY-MM-DD
        date          :end_date # YYYY-MM-DD
        decimal       :hours
        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        has_many      :timesheet_lines

        validates_presence_of :tilesheet_id, :unless => :new_record?
        validates_presence_of :employee_id, :start_date, :end_date, :status, :hours
        validates_inclusion_of :status, :in => TIMESHEET_STATUS_CODES
      end

    end
  end
end
