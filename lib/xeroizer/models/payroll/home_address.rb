module Xeroizer
  module Record
    module Payroll
    
      class HomeAddressModel < PayrollBaseModel
          
      end
      
      class HomeAddress < PayrollBase
        
        string      :address_line_1
        string      :address_line_2
        string      :address_line_3
        string      :address_line_4
        string      :city
        string      :region
        string      :postal_code
        string      :country

      end

    end 
  end
end
