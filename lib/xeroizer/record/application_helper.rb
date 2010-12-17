module Xeroizer
  module Record
    module ApplicationHelper
      
      def record(record_type)
        define_method record_type do
          var_name = "@#{record_type}_cache".to_sym
          unless instance_variable_defined?(var_name)
            instance_variable_set(var_name, Xeroizer::Record.const_get("#{record_type}Model".to_sym).new(self, record_type.to_s))
          end
          instance_variable_get(var_name)
        end  
      end
      
    end
  end
end