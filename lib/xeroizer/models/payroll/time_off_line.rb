module Xeroizer
  module Record
    module Payroll

      class TimeOffLineModel < PayrollBaseModel

      end

      class TimeOffLine < PayrollBase

        guid :time_off_type_id, :api_name => 'TimeOffTypeID'
        decimal :hours
        decimal :balance

        validates_presence_of :time_off_type_id, :unless => :new_record?
      end

    end
  end
end