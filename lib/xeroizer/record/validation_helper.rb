Dir.foreach(File.join(File.dirname(__FILE__), 'validators/')) { | file | require File.join(File.dirname(__FILE__), "validators/#{file}") if file =~ /\.rb$/ }

module Xeroizer
  module Record
    module ValidationHelper
      
      def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        
        def validates_presence_of(*args)
          options = args.extract_options!
          self.validators ||= []
          args.flatten.each do | attribute |
            self.validators << Validator::PresenceOfValidator.new(attribute, options)
          end
        end
        
      end
      
      module InstanceMethods
      
        def valid?
          @errors = []
          self.class.validators.each do | validator |
            validator.validate(self)
          end
          @errors.size == 0
        end
        
        def errors_for(attribute)
          if errors.is_a?(Array)
            errors.find_all { | (attr, msg) | attr == attribute }
          end
        end
        
      end
      
    end
  end
end