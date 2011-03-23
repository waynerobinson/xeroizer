module Xeroizer
  module Record
    module ApplicationHelper
      
      # Factory for new BaseModel instances with the class name `record_type`.
      # Only creates the instance if one doesn't already exist.
      #
      # @param [Symbol] record_type Symbol of the record type (e.g. :Invoice)
      # @return [BaseModel] instance of BaseModel subclass matching `record_type`
      def record(record_type)
        define_method record_type do
          var_name = "@#{record_type}_cache".to_sym
          unless instance_variable_defined?(var_name)
            instance_variable_set(var_name, Xeroizer::Record.const_get("#{record_type}Model".to_sym).new(self, record_type.to_s))
          end
          instance_variable_get(var_name)
        end  
      end
      
      def report(report_type)
        define_method report_type do
          var_name = "@#{report_type}_cache".to_sym
          unless instance_variable_defined?(var_name)
            instance_variable_set(var_name, Xeroizer::Report::Factory.new(self, report_type.to_s))
          end
          instance_variable_get(var_name)
        end
      end
      
    end
  end
end