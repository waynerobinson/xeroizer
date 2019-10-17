module Xeroizer
  module Record
    module Payroll
    
      class TimesheetModel < PayrollBaseModel
          
        set_permissions :read, :write, :update
          
      end
      
      class Timesheet < PayrollBase
        
        set_primary_key :timesheet_id

        guid          :timesheet_id
        guid          :employee_id
        date          :start_date
        date          :end_date
        decimal       :hours
        string        :status

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
  
        has_many      :timesheet_lines

        validates_presence_of :start_date, :end_date, :employee_id

      end

    end 
  end
end
