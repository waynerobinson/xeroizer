module Xeroizer
  module Record
    module Payroll
    
      class SuperMembershipModel < PayrollBaseModel
          
      end
      
      # child of Employee
      class SuperMembership < PayrollBase

        guid        :super_membership_id
        guid        :super_fund_id
        string      :employee_number

      end

    end 
  end
end
