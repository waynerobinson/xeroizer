module Xeroizer
  module Record
    module Payroll
    
      class TaxDeclarationModel < PayrollBaseModel
      end
      
      class TaxDeclaration < PayrollBase
        
        EMPLOYMENT_BASIS = {
          'FULLTIME' => '',
          'PARTTIME' => '',
          'CASUAL' => '',
          'LABOURHIRE' => '',
          'SUPERINCOMESTREAM' => ''
          
        } unless defined?(EMPLOYMENT_BASIS)
        EMPLOYMENT_BASISES = EMPLOYMENT_BASIS.keys.sort

        TFN_EXEMPTION_TYPE = {
          'NOTQUOTED' => 'Employee has not provided a TFN.',
          'PENDING' => 'Employee has made a separate application or Enquiry to the ATO for a new or existing TFN.',
          'PENSIONER' => 'Employee is claiming that they are in receipt of a pension, benefit or allowance.',
          'UNDER18' => 'Employee is claiming an exemption as they are under the age of 18 and do not earn enough to pay tax.'
        } unless defined?(TFN_EXEMPTION_TYPE)
        TFN_EXEMPTION_TYPES = TFN_EXEMPTION_TYPE.keys.sort

        guid        :employee_id, :api_name => 'EmployeeID'
        string      :tax_file_number
        
        string      :tfn_exemption_type, :api_name => 'TFNExemptionType'
        string      :employment_basis

        boolean      :australian_resident_for_tax_purposes
        boolean      :tax_free_threshold_claimed
        boolean      :has_help_debt, :api_name => 'HasHELPDebt'
        boolean      :has_sfss_debt, :api_name => 'HasSFSSDebt'
        boolean      :eligible_to_receive_leave_loading

        decimal      :tax_offset_estimated_amount
        decimal      :upward_variation_tax_withholding_amount
        decimal      :approved_withholding_variation_percentage

        datetime_utc :updated_date_utc, :api_name => 'UpdatedDateUTC'

        validates_inclusion_of :employment_basis, :in => EMPLOYMENT_BASISES
        validates_inclusion_of :tfn_exemption_type, :in => TFN_EXEMPTION_TYPES, :allow_blanks => true
      end

    end 
  end
end
