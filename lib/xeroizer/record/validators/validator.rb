module Xeroizer
  module Record
    
    class Validator
      
      attr_reader :attribute
      attr_reader :options
      
      def initialize(attribute, options = {})
        @attribute = attribute
        @options = options
      end
  
      def validate(record)
        run_validator = true
        run_validator = false if options[:if] && !options[:if].call(record)
        run_validator = false if options[:unless] && options[:unless].call(record)
        valid?(record) if run_validator
      end
  
    end
    
  end
end
