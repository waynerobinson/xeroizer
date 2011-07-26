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
        valid?(record) if run_validator?(record, options)
      end

      def run_validator?(record, options)
        return false if options[:if] && !condition?(record, options[:if])
        return false if options[:unless] && condition?(record, options[:unless])
        true
      end

      def condition?(record, condition)
        return condition.call(record) if condition.respond_to? :call
        return record.send(condition) if condition.is_a? Symbol
        raise "Validation condition must be a Symbol or an Object that responds to call"
      end

    end
    
  end
end
