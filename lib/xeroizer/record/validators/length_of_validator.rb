module Xeroizer
  module Record
    
    class Validator
  
      class LengthOfValidator < Validator
        
        def valid?(record)
          if options[:max] && record[attribute].to_s.length > options[:max]
            record.errors << [attribute, options[:message] || "must be shorter than #{options[:max]} characters"]
          end

          if options[:min] && record[attribute].to_s.length < options[:min]
            record.errors << [attribute, options[:message] || "must be greater than #{options[:min]} characters"]
          end
        end
        
      end
  
    end
    
  end
end
