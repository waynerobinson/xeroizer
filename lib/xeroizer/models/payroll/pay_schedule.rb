module Xeroizer
  module Record
    module Payroll

      class PayScheduleModel < PayrollBaseModel
        set_permissions :read, :write, :update
      end

      class PaySchedule < PayrollBase
        PAY_SCHEDULE_TYPES = [
          "WEEKLY",
          "MONTHLY",
          "BIWEEKLY",
          "QUARTERLY",
          "SEMIMONTHLY",
          "FOURWEEKLY",
          "YEARLY"
        ]

        set_primary_key :pay_schedule_id

        guid :pay_schedule_id
        string :pay_schedule_name
        date :payment_date
        date :start_date
        string :schedule_type
        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        validates_inclusion_of :schedule_type, :in => PAY_SCHEDULE_TYPES
      end
    end
  end
end
