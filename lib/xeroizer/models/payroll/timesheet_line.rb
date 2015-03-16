module Xeroizer
  module Record
    module Payroll

      class TimesheetLineModel < PayrollBaseModel
      end

      class TimesheetLine < PayrollBase

        guid          :earnings_rate_id, :api_name => 'EarningsRateID'
        guid          :tracking_item_id, :api_name => 'TrackingItemID'
        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        has_many      :number_of_units

        validates_presence_of :earnings_rate_id
      end

    end
  end
end
