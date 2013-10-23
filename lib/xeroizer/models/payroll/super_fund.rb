module Xeroizer
  module Record
    module Payroll
    
      class SuperFundModel < PayrollBaseModel
        set_permissions :read, :write, :update          
      end
      
      class SuperFund < PayrollBase
        SUPER_FUND_TYPE = {
          'REGULATED' => 'Regulated Superannuation Fund: a super fund regulated by APRA',
          'SMSF' => 'Self Managed Super Fund: a super fund managed by you or your company'
        } unless defined?(SUPER_FUND_TYPE)
        SUPER_FUND_TYPES = SUPER_FUND_TYPE.keys.sort
        
        set_primary_key :super_fund_id

        guid        :super_fund_id, :api_name => 'SuperFundID'
        string      :type
        string      :name
        string      :abn, :api_name => 'ABN'
        string      :spin, :api_name => 'SPIN'
        string      :bsb, :api_name => 'BSB'
        string      :account_number
        string      :account_name
        string      :employeer_number

        validates_inclusion_of :type, :in => SUPER_FUND_TYPES
        validates_length_of :name, length: { maximum: 76 }, :allow_blanks => true
        validates_length_of :bsb, length: { is: 6 }, :allow_blanks => true, :unless => :regulated?
        validates_length_of :account_number, length: { maximum: 9 }, :allow_blanks => true, :unless => :regulated?
        validates_length_of :account_name, length: { maximum: 32 }, :allow_blanks => true, :unless => :regulated?
        validates_length_of :employeer_number, length: { maximum: 20 }, :allow_blanks => true, :unless => :regulated?

        public

        def regulated?
          type == 'REGULATED'
        end

      end

    end 
  end
end