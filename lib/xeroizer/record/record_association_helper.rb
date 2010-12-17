module Xeroizer
  module Record
    module RecordAssociationHelper
      
      def self.included(base)
        base.extend(ClassMethods)    
      end
      
      module ClassMethods
        
        def belongs_to(field_name, options = {})
          internal_field_name = options[:internal_name] || field_name
          internal_singular_field_name = internal_field_name.to_s.singularize
          define_simple_attribute(field_name, :belongs_to, options)
        
          # Create a #build_record_name method to build the record.
          define_method "build_#{internal_singular_field_name}" do | *args |
            attributes = args.size == 1 ? args.first : {}
          
            # The name of the record model.
            model_name = options[:model_name] ? options[:model_name].to_sym : field_name.to_s.singularize.camelize.to_sym
          
            # The record's parent instance for this current application.
            model_parent = new_model_class(model_name)
          
            # Create a new record, binding it to it's parent instance.
            record = Xeroizer::Record.const_get(model_name).build(attributes, model_parent)
            self.attributes[field_name] = record
          end
        end
      
        def has_many(field_name, options = {})
          internal_field_name = options[:internal_name] || field_name
          internal_singular_field_name = internal_field_name.to_s.singularize
        
          define_simple_attribute(field_name, :has_many, options)
                  
          # Create an #add_record_name method to build the record and add to the attributes.
          define_method "add_#{internal_singular_field_name}" do | *args |
            # The name of the record model.
            model_name = options[:model_name] ? options[:model_name].to_sym : field_name.to_s.singularize.camelize.to_sym

            # The record's parent instance for this current application.
            model_parent = new_model_class(model_name)
          
            # The class of this record.
            record_class = Xeroizer::Record.const_get(model_name)

            # Parse the *args variable so that we can use this method like:
            #   add_record({fields}, {fields}, ...)
            #   add_record(record_one, record_two, ...)
            #   add_record([{fields}, {fields}], ...)
            #   add_record(key => val, key2 => val)
            records = []
            if args.size == 1 && args.first.is_a?(Array)
              records = args.first
            elsif args.size > 0 
              records = args
            else
              raise StandardError.new("Invalid arguments for #{self.class.name}#add_#{internal_singular_field_name}(#{args.inspect}).")
            end
          
            # Add each record.
            records.each do | record |
              record = record_class.build(record, model_parent) if record.is_a?(Hash)
              raise StandardError.new("Record #{record.class.name} is not a #{record_class.name}.") unless record.is_a?(record_class)
              self.attributes[field_name] ||= []
              self.attributes[field_name] << record
            end
          end
          
        end
        
      end
      
    end
  end
end