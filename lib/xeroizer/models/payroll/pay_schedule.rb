module Xeroizer
  module Record
    module Payroll

      class PayScheduleModel < PayrollBaseModel

        set_permissions :read, :write, :update

      end

      class PaySchedule < PayrollBase

        SCHEDULE_TYPES = {
          'WEEKLY' => 'Once per week on the same Day each week',
          'MONTHLY' => 'Once a month on the same Day each month',
          'BIWEEKLY' => 'Every 14 days on the same Day each period',
          'QUARTERLY' => 'Once a quarter on the same Day',
          'SEMIMONTHLY' => 'Twice a month on the same 2 Days each period',
          'FOURWEEKLY' => '',
          'YEARLY' => ''
        } unless defined?(SCHEDULE_TYPES)

        set_primary_key :pay_schedule_id

        guid :pay_schedule_id
        string :pay_schedule_name
        datetime :payment_date
        datetime :start_date
        string :schedule_type

        validates_inclusion_of :schedule_type, :in => SCHEDULE_TYPES
      end
    end
  end
end