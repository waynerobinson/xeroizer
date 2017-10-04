module Xeroizer
  module Record
    module Payroll

      class TimesheetLineModel < PayrollBaseModel

        set_permissions :read, :write, :update # UK

      end

      class TimesheetLine < PayrollBase

        # AU
        guid          :earnings_rate_id
        guid          :tracking_item_id

        # USA
        guid          :earnings_type_id
        guid          :work_location_id

        has_array     :number_of_units, :api_child_name => 'NumberOfUnit'

        # UK
        datetime      :date
        guid          :timesheet_id # used to make the URL

        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        def api_url
          "Timesheets/#{attributes[:timesheet_id]}/lines"
        end

      end

    end
  end
end
