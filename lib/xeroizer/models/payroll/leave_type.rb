module Xeroizer
  module Record
    module Payroll
    
      class LeaveTypeModel < PayrollBaseModel
      end
      
      class LeaveType < PayrollBase
        
        set_primary_key :leave_type_id

        guid :leave_type_id, :api_name => 'LeaveTypeID'
        string        :name
        string        :type_of_units
        boolean       :is_paid_leave
        boolean       :show_on_payslip

        decimal       :normal_entitlement
        decimal       :leave_loading_rate
        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        validates_presence_of :leave_type_id, :unless => :new_record?
        validates_presence_of :name
        validates_length_of :name, length: { maximum: 50 }
        validates_presence_of :type_of_units
        validates_length_of :type_of_units, length: { maximum: 50 }
        validates_presence_of :is_paid_leave
        validates_presence_of :show_on_payslip
      end

    end 
  end
end