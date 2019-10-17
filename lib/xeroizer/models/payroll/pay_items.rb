module Xeroizer
  module Record
    module Payroll
      class PayItemModel < PayrollBaseModel

        set_permissions :read, :write, :update

        set_standalone_model true
        set_xml_root_name 'PayItems'
        set_xml_node_name 'PayItems'
      end

      class PayItem < PayrollBase
        set_primary_key false

        has_many      :earnings_rates # AU
        has_many      :earnings_types # US
        has_many      :benefit_types
        has_many      :deduction_types
        has_many      :leave_types
        has_many      :reimbursement_types
        has_many      :time_off_types
      end

    end
  end
end
