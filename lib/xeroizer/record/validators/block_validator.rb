module Xeroizer
  module Record
    class Validator
      class BlockValidator < Validator
        def valid?(record)
          fail "No block provided" unless options[:block]
          
          result = record.instance_eval &options[:block]
          
          unless result == true
            record.errors << [attribute, message]
          end
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
