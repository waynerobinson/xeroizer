module Xeroizer
  module Record
    module Payroll

      class TimeOffBalanceModel < PayrollBaseModel

      end

      # child of Employee
      # https://developer.xero.com/documentation/payroll-api-us/timeoff-balances/
      class TimeOffBalance < PayrollBase

        string      :time_off_name
        guid        :time_off_type_id
        decimal     :number_of_units
        string      :type_of_units

      end

    end
  end
end
