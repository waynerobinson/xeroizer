module Xeroizer
  module Record
    module Payroll

      class NumberOfUnitModel < PayrollBaseModel
        set_xml_node_name 'NumberOfUnits'
      end

      class NumberOfUnit < PayrollBase

        decimal       :number_of_unit

        validates_presence_of :number_of_unit
      end

    end
  end
end
