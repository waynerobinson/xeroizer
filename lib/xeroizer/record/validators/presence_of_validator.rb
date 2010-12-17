module Xeroizer
  module Record
    
    class Validator
  
      class PresenceOfValidator < Validator
        
        def valid?(record)
          if record[attribute].nil? || record[attribute].to_s == ''
            record.errors << [attribute, options[:message] || "can't be blank"]
          end
        end
        
      end
  
    end
    
  end
end
