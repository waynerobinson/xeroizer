module Xeroizer
  module Record
    module Payroll

      class PeriodModel < PayrollBaseModel

      end

      class Period < PayrollBase

        decimal     :number_of_units
        date        :pay_period_start_date
        date        :pay_period_end_date
        date        :period_start_date
        date        :period_end_date
        string      :leave_period_status
        string      :period_status

      end

    end
  end
end
