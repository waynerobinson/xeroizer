Dir.foreach(File.join(File.dirname(__FILE__), 'validators/')) { | file | require File.join(File.dirname(__FILE__), "validators/#{file}") if file =~ /\.rb$/ }

module Xeroizer
  module Record
    module ValidationHelper
      
      def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
      end
      
      module ClassMethods
        
        # Adds a validator config for each attribute specified in args.
        def validates_with_validator(validator, args)
          options = args.extract_options!
          
          self.validators ||= []
          args.flatten.each do | attribute |
            self.validators << validator.new(attribute, options)
          end
        end
        
        def validates_associated(*args)
          validates_with_validator(Validator::AssociatedValidator, args)
        end
        
        def validates_inclusion_of(*args)
          validates_with_validator(Validator::InclusionOfValidator, args)
        end

        def validates_presence_of(*args)
          validates_with_validator(Validator::PresenceOfValidator, args)
        end

        def validates_length_of(*args)
          validates_with_validator(Validator::LengthOfValidator, args)
        end 

        def validates(*args, &block)
          fail "Block required" unless block_given?

          if args.last.is_a? Hash
            args.last[:block] = block
          else
            args << { :block => block }
          end

          validates_with_validator(Validator::BlockValidator, args)
        end
      end
      
      module InstanceMethods
      
        def valid?
          @errors = []
          if self.class.validators
            self.class.validators.each do | validator |
              validator.validate(self)
            end
          end
          @errors.size == 0
        end
        
        def errors_for(attribute)
          if errors.is_a?(Array)
            errors.find_all { | (attr, msg) | attr == attribute }.map { | (attr, msg) | msg }
          end
        end
        
      end
      
    end
  end
end
