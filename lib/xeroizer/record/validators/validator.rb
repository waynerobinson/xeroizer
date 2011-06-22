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
        run_validator = false if options[:if] && !condition?(record, options[:if])
        run_validator = false if options[:unless] && condition?(record, options[:unless])
        valid?(record) if run_validator
      end
  
      def condition?(record, condition)
        return condition.call(record) if condition.respond_to? :call
        return record.send(condition) if condition.is_a? Symbol
        raise "Validation condition must be a Proc, a Symbol or a Module that responds to call"
      end

    end
    
  end
end
