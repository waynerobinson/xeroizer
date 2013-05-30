module Xeroizer
  module Record
    module Payroll
    
      class TimesheetLineModel < PayrollBaseModel
          
      end
      
      class TimesheetLine < PayrollBase

        guid          :earnings_rate_id
        guid          :tracking_item_id # TODO: belongs to a http://developer.xero.com/api/Tracking%20Categories/ (optionally? the docs don't have any examples)

        has_array     :number_of_units

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

      end

    end 
  end
end
