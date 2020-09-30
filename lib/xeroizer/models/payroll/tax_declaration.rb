module Xeroizer
  module Record
    module Payroll

      class TaxDeclarationModel < PayrollBaseModel

      end

      class TaxDeclaration < PayrollBase

        guid         :employee_id
        string       :employment_basis
        string       :tax_file_number
        string       :tfn_exemption_type, :api_name => 'TFNExemptionType'
        boolean      :australian_resident_for_tax_purposes
        string       :residency_status, :api_name => 'ResidencyStatus'
        boolean      :tax_free_threshold_claimed
        decimal      :tax_offset_estimated_amount
        boolean      :has_help_debt, :api_name => 'HasHELPDebt'
        boolean      :has_sfss_debt, :api_name => 'HasSFSSDebt'
        decimal      :upward_variation_tax_withholding_amount
        boolean      :eligible_to_receive_leave_loading
        decimal      :approved_withholding_variation_percentage

      end

    end
  end
end
