module Xeroizer
  module Record
    
    class PayrollArrayBaseModel < PayrollBaseModel

      class_inheritable_attributes :api_controller_name
      class_inheritable_attributes :permissions
      class_inheritable_attributes :xml_root_name
      class_inheritable_attributes :optional_xml_root_name
      class_inheritable_attributes :xml_node_name

      attr_accessor :value
      
      def to_s
        value
      end

    end

  end
end
