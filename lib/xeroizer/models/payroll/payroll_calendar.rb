module Xeroizer
  module Record
    module Payroll
    
      class PayrollCalendarModel < PayrollBaseModel
          
        set_permissions :read, :write
          
      end
      
      class PayrollCalendar < PayrollBase
        
        set_primary_key :payroll_calendar_id

        guid          :payroll_calendar_id

        string        :name
        string        :calendar_type # http://developer.xero.com/payroll-api/types-and-codes/#CalendarTypes
        date          :start_date
        date          :payment_date
  
        validates_presence_of :name, :calendar_type, :start_date, :payment_date

      end

    end 
  end
end
