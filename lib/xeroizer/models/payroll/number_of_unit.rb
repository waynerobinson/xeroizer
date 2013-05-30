module Xeroizer
  module Record
    module Payroll
    
      class NumberOfUnitModel < PayrollArrayBaseModel
          
      end
      
      class NumberOfUnit < PayrollArrayBase

        decimal      :value

      end

    end 
  end
end
