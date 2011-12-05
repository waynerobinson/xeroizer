module Xeroizer
  module Record
    class Validator
      class BlockValidator < Validator
        def valid?(record)
          fail "No block provided" unless options[:block]
          
          result = record.instance_eval &options[:block]
          
          record.errors << [attribute, message] unless result == true
        end

        private
        
        def message
          supplied_message = options[:message] || ""
          supplied_message.empty? ? "block condition failed" : supplied_message
        end
      end
    end
  end
end
