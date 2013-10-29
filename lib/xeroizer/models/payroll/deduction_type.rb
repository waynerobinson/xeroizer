module Xeroizer
  module Record
    module Payroll
    
      class DeductionTypeModel < PayrollBaseModel
      end
      
      class DeductionType < PayrollBase

        set_primary_key :deduction_type_id

        guid          :deduction_type_id, :api_name => 'DeductionTypeID'
        string        :name
        string        :account_code
        boolean       :reduces_tax
        boolean       :reduces_super
        datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'

        validates_presence_of :deduction_type_id, :unless => :new_record?
        validates_presence_of :name
        validates_length_of :name, length: { maximum: 50 }
        validates_presence_of :account_code
        validates_presence_of :reduces_tax
        validates_presence_of :reduces_super
      end

    end 
  end
end