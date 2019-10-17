module Xeroizer
  module Record
    module Payroll

      class PayTemplateModel < PayrollBaseModel

        set_all_children_are_subtypes true
        set_xml_root_name 'PayTemplate'
        set_xml_node_name 'PayTemplate'
      end

      class PayTemplate < PayrollBase

        set_primary_key false
        
        has_many      :earnings_lines
        has_many      :deduction_lines
        has_many      :super_lines
        has_many      :reimbursement_lines
        has_many      :leave_lines

        # US Payroll fields
        has_many      :benefit_lines

      end

    end
  end
end
