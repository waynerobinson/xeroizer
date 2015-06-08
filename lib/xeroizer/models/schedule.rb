module Xeroizer
  module Record

    class ScheduleModel < BaseModel

    end

    class Schedule < Base

      UNIT = {
        'WEEKLY'  => 'Weekly',
        'MONTHLY' => 'Monthly',
      } unless defined?(UNIT)
      UNITS = UNIT.keys.sort

      PAYMENT_TERM = {
        'DAYSAFTERBILLDATE'  => 'day(s) after bill date',
        'DAYSAFTERBILLMONTH' => 'day(s) after bill month',
        'OFCURRENTMONTH'     => 'of the current month',
        'OFFOLLOWINGMONTH'   => 'of the following month',
      } unless defined?(PAYMENT_TERM)
      PAYMENT_TERMS = PAYMENT_TERM.keys.sort

      integer :period
      string  :unit
      integer :due_date
      string  :due_date_type
      date    :start_date
      date    :next_scheduled_date
      date    :end_date

      validates_inclusion_of :unit, :in => UNITS
      validates_inclusion_of :due_date_type, :in => PAYMENT_TERMS

    end

  end
end
