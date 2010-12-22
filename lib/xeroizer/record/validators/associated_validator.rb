module Xeroizer
  module Record
    
    class Validator
  
      class AssociatedValidator < Validator
        
        def valid?(record)
          case record.class.fields[attribute][:type]
            when :belongs_to
              return true if options[:allow_blanks] && record[attribute].nil?
              unless record[attribute].is_a?(Xeroizer::Record::Base) && record[attribute].valid?
                record.errors << [attribute, options[:message] || "must be valid"]
              end
              
            when :has_many
              return true if options[:allow_blanks] && (record[attribute].nil? || (record[attribute].is_a?(Array) && record[attribute].size == 0))
              if record[attribute].is_a?(Array) && record[attribute].size > 0
                unless record[attribute].all? { | r | r.is_a?(Xeroizer::Record::Base) && r.valid? }
                  record.errors << [attribute, options[:message] || "must all be valid"]
                end
              else
                record.errors << [attribute, "must have one or more records"] 
              end
          end
        end
        
      end
  
    end
    
  end
end
