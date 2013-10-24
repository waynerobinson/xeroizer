module Xeroizer
  module Record
    module Payroll
    
      class SuperMembershipModel < PayrollBaseModel
          
      end
      
      class SuperMembership < PayrollBase
        
        set_primary_key :super_membership_id

        guid        :super_membership_id, :api_name => 'SuperMembershipID'
        string      :employee_number
        string      :super_fund_id, :api_name => 'SuperFundID'
      end

    end 
  end
end