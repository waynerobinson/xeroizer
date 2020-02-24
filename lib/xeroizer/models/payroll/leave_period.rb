module Xeroizer
  module Record
    module Payroll
      class LeavePeriodModel < PayrollBaseModel
      end

      class LeavePeriod < PayrollBase
        decimal     :number_of_units
        date        :pay_period_start_date
        date        :pay_period_end_date
        string      :leave_period_status
      end
    end
  end
end
