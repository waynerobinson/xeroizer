module Xeroizer
  module Record
    module Payroll
    
      class TimesheetLineModel < PayrollBaseModel
          
      end
      
      class TimesheetLine < PayrollBase

        guid          :earnings_rate_id
        guid          :tracking_item_id

        has_array     :number_of_units, :api_child_name => 'NumberOfUnit'

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

      end

    end 
  end
end
