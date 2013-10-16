module Xeroizer
  module Record
    
    class Validator
  
      class LengthValidator < Validator
        
        def valid?(record)
          if options[:length] && options[:length].is_a?(Hash)
            if options[:allow_blanks]
              return true unless record[attribute].present?
            end       
            if options[:length][:is].present? && record[attribute].to_s.length != options[:length][:is]
              record.errors << [attribute, options[:message] || "should be #{options[:length][:is]} symbols in length."]
            end

            if options[:length][:minimum].present? && record[attribute].to_s.length < options[:length][:minimum]
              record.errors << [attribute, options[:message] || "should be at least #{options[:length][:minimum]} symbols in length."]
            end

            if options[:length][:maximum].present? && record[attribute].to_s.length > options[:length][:maximum]
              record.errors << [attribute, options[:message] || "should not exceed #{options[:length][:maximum]} symbols in length."]
            end
          end
        end
        
      end
  
    end
    
  end
end
