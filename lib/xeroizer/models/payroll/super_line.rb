module Xeroizer
  module Record
    module Payroll
    
      class SuperLineModel < PayrollBaseModel
          
      end
      
      # child of PayTemplate
      class SuperLine < PayrollBase

        guid          :super_membership_id
        string        :contribution_type # http://developer.xero.com/payroll-api/types-and-codes#SuperannuationContributionType
        string        :calculation_type # http://developer.xero.com/payroll-api/types-and-codes#SuperannuationCalculationType
        string        :expense_account_code
        string        :liability_account_code

        decimal       :minimum_monthly_earnings
        decimal       :percentage

      end

    end 
  end
end
