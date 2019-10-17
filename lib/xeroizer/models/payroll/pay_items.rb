module Xeroizer
  module Record
    module Payroll
      class PayItemsModel < PayrollBaseModel

        set_permissions :read

      end

      class PayItems < PayrollBase

        has_many      :earnings_types
        has_many      :benefit_types
        has_many      :deduction_types
        has_many      :reimbursement_types
        has_many      :time_off_types

      end

      # TODO: To be merged with the pluralized versions
      class PayItemModel < PayrollBaseModel
          
        set_permissions :read, :write, :update

        set_all_children_are_subtypes true
        set_xml_root_name 'PayItems'
        set_xml_node_name 'PayItems'
      end
      
      class PayItem < PayrollBase

        set_primary_key false
        
        has_many      :earnings_rates
        has_many      :earnings_types
        has_many      :benefit_types
        has_many      :deduction_types
        has_many      :leave_types
        has_many      :reimbursement_types
        has_many      :time_off_types


      end

    end 
  end
end
