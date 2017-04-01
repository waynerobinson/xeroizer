module Xeroizer
  module Record
    module Payroll

      class LeaveLineModel < PayrollBaseModel

      end

      class LeaveLine < PayrollBase

        LEAVE_TYPE_CALCULATION_TYPE = {
          'FIXEDAMOUNTEACHPERIOD' => 'You can enter a manually calculated rate for the accrual, accrue a fixed amount of leave each pay period based on an annual entitlement (for example, if you pay your employees monthly, you would accrue 1/12th of their annual entitlement each month), or accrue an amount relative to the number of hours an employee worked in the pay period',
          'ENTERRATEINPAYTEMPLATE' => '',
          'BASEDONORDINARYEARNINGS' => ''
        } unless defined?(LEAVE_TYPE_CALCULATION_TYPE)

        guid :leave_type_id, :api_name => 'LeaveTypeID'
        string :calculation_type

        decimal :annual_number_of_units
        decimal :full_time_number_of_units_per_period
        decimal :number_of_units

        validates_presence_of :leave_type_id, :calculation_type, :unless => :new_record?
        validates_inclusion_of :calculation_type, :in => LEAVE_TYPE_CALCULATION_TYPE
      end

    end
  end
end