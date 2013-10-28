module Xeroizer
  module Record
    module Payroll
    
      class SuperLineModel < PayrollBaseModel
          
      end
      
      class SuperLine < PayrollBase

        SUPERANNUATION_CONTRIBUTION_TYPE = {
          'SGC' => 'Mandatory 9% contribution',
          'SALARYSACRIFICE' => 'Pre-tax reportable employer superannuation contribution, which is displayed separately on payment summaries',
          'EMPLOYERADDITIONAL' => 'Additional employer superannuation contribution, which is displayed as RESC on payment summaries',
          'EMPLOYEE' => 'Post-tax employee superannuation contribution'
        } unless defined?(SUPERANNUATION_CONTRIBUTION_TYPE)
        SUPERANNUATION_CONTRIBUTION_TYPES = SUPERANNUATION_CONTRIBUTION_TYPE.keys.sort
        
        SUPERANNUATION_CALCULATION_TYPE = {
          'FIXEDAMOUNT' => 'For voluntary superannuation, the contribution amount can be a fixed rate or a percentage of earnings. For SGC contributions it must be a percentage',
          'PERCENTAGEOFEARNINGS' => '',
          'STATUTORY' => ''
        } unless defined?(SUPERANNUATION_CALCULATION_TYPE)
        SUPERANNUATION_CALCULATION_TYPES = SUPERANNUATION_CALCULATION_TYPE.keys.sort

        guid  :super_membership_id, :api_name => 'SuperMembershipID'
        string  :contribution_type
        string  :calculation_type
        integer :expense_account_code
        integer :liability_account_code

        decimal :minimum_monthly_earnings
        decimal :percentage

        validates_presence_of :super_membership_id
        validates_presence_of :contribution_type, :calculation_type, :expense_account_code, :liability_account_code
        validates_inclusion_of :contribution_type, :in => SUPERANNUATION_CONTRIBUTION_TYPES
        validates_inclusion_of :calculation_type, :in => SUPERANNUATION_CALCULATION_TYPES
      end

    end 
  end
end