module Xeroizer
  module Record
    class Validator
      class BlockValidator < Validator
        def valid?(record)
          fail "No block provided" unless options[:block]
          
          result = record.instance_eval &options[:block]
          
          unless result == true
            record.errors << [attribute, options[:message] || "block condition failed"]
          end
        end
      end
    end
  end
end
