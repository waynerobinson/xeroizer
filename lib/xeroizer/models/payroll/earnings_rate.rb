module Xeroizer
  module Record
    module Payroll
    
      class EarningsRateModel < PayrollBaseModel
      end
      
      class EarningsRate < PayrollBase
        
        EARNINGS_RATE_EARNINGS_TYPE = {
          'FIXED' => '',
          'ORDINARYTIMEEARNINGS' => '',
          'OVERTIMEEARNINGS' => '',
          'ALLOWANCE' => ''
        } unless defined?(EARNINGS_RATE_EARNINGS_TYPE)
        EARNINGS_RATE_EARNINGS_TYPES = EARNINGS_RATE_EARNINGS_TYPE.keys.sort

        EARNINGS_RATE_RATE_TYPE = {
          'FIXEDAMOUNT' => '',
          'MULTIPLE' => 'Multiple of Employee’s Ordinary Earnings Rate: an earnings rate which is derived from an employee’s ordinary earnings rate',
          'RATEPERUNIT' => 'An earnings rate allowing entry of a rate per unit'
        } unless defined?(EARNINGS_RATE_RATE_TYPE)
        EARNINGS_RATE_RATE_TYPES = EARNINGS_RATE_RATE_TYPE.keys.sort

        set_primary_key :earnings_rate_id
        
        guid          :earnings_rate_id, :api_name => 'EarningsRateID'
        string        :name
        string        :account_code
        string        :type_of_units
        boolean       :is_exempt_from_tax
        boolean       :is_exempt_from_super
        string        :earnings_type

        string        :rate_type
        decimal       :rate_per_unit
        decimal       :multiplier
        boolean       :accrue_leave
        decimal       :amount
        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
        
        validates_presence_of :earnings_rate_id, :unless => :new_record?
        validates_presence_of :name
        validates_length_of :name, length: { maximum: 100 }
        validates_presence_of :account_code
        validates_presence_of :type_of_units, :if => :rate_per_unit?
        validates_length_of :type_of_units, length: { maximum: 50 }
        validates_presence_of :is_exempt_from_tax
        validates_presence_of :is_exempt_from_super
        
        validates_presence_of :earnings_type
        validates_inclusion_of :earnings_type, :in => EARNINGS_RATE_EARNINGS_TYPES
        validates_inclusion_of :rate_type, :in => EARNINGS_RATE_RATE_TYPES

        def rate_per_unit?
          self.rate_type == 'RATEPERUNIT'
        end
      end
    end 
  end
end
