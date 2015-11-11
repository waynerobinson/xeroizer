module Xeroizer
  module Record
    module Payroll
    
      class LeaveBalanceModel < PayrollBaseModel
          
      end
      
      # child of Employee
      class LeaveBalance < PayrollBase

        string      :leave_name
        guid        :leave_type_id
        decimal     :number_of_units
        string      :type_of_units

      end

    end 
  end
end
