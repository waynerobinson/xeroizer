require 'xeroizer/record/base_model_http_proxy'

module Xeroizer
  module Record
    
    class PayrollBaseModel < Xeroizer::Record::BaseModel

      class_inheritable_attributes :api_controller_name
      class_inheritable_attributes :permissions
      class_inheritable_attributes :xml_root_name
      class_inheritable_attributes :optional_xml_root_name
      class_inheritable_attributes :xml_node_name
      
      include BaseModelHttpProxy

      public
        
        def model_class
          @model_class ||= Xeroizer::Record::Payroll.const_get(model_name.to_sym)
        end

        def parse_response(response_xml, options = {})
          super(response_xml, {:base_module => Xeroizer::Record::Payroll}.merge(options))
        end

    end

  end
end
