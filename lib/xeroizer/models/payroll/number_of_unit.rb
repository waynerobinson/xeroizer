module Xeroizer
  module Record
    module Payroll

      class NumberOfUnitModel < PayrollBaseModel
        set_skip_xml_node_name true
      end

      class NumberOfUnit < PayrollBase

        decimal       :number_of_unit

        validates_presence_of :number_of_unit
      end

    end
  end
end
