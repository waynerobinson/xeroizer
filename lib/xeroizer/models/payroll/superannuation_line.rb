module Xeroizer
  module Record
    module Payroll
    
      class SuperannuationLineModel < PayrollBaseModel
          
      end
      
      # child of Payslip. Same as SuperLine.
      class SuperannuationLine < PayrollBase

        guid          :super_membership_id
        string        :contribution_type # http://developer.xero.com/payroll-api/types-and-codes#SuperannuationContributionType
        string        :calculation_type # http://developer.xero.com/payroll-api/types-and-codes#SuperannuationCalculationType
        string        :expense_account_code
        string        :liability_account_code

        date          :payment_date_for_this_period

        decimal       :minimum_monthly_earnings
        decimal       :percentage
        decimal       :amount

      end

    end 
  end
end
