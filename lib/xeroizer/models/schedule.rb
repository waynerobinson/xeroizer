module Xeroizer
  module Record

    class ScheduleModel < BaseModel

    end

    class Schedule < Base

      UNIT = {
        'WEEKLY'  => 'Weekly',
        'MONTHLY' => 'Monthly',
      } unless defined?(UNIT)

      PAYMENT_TERM = {
        'DAYSAFTERBILLDATE'  => 'day(s) after bill date',
        'DAYSAFTERBILLMONTH' => 'day(s) after bill month',
        'OFCURRENTMONTH'     => 'of the current month',
        'OFFOLLOWINGMONTH'   => 'of the following month',
      } unless defined?(PAYMENT_TERM)

      integer :period
      string  :unit
      integer :due_date
      string  :due_date_type
      date    :start_date
      date    :next_scheduled_date
      date    :end_date

    end

  end
end
