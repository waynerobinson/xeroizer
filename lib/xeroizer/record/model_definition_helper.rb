module Xeroizer
  module Record
    module ModelDefinitionHelper
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods

        # Possible primary keys. At least one of these must exist before attempting to update a record.
        def set_possible_primary_keys(*args)
          args = [args] unless args.is_a?(Array)
          self.possible_primary_keys = args
        end
              
        # Helper methods used to define the fields this model has.
        def string(field_name, options = {});     define_simple_attribute(field_name, :string, options); end
        def boolean(field_name, options = {});    define_simple_attribute(field_name, :boolean, options); end
        def integer(field_name, options = {});    define_simple_attribute(field_name, :integer, options); end
        def decimal(field_name, options = {});    define_simple_attribute(field_name, :decimal, options); end
        def date(field_name, options = {});       define_simple_attribute(field_name, :date, options); end
        def datetime(field_name, options = {});   define_simple_attribute(field_name, :datetime, options); end
              
        # Helper method to simplify field definition. 
        # Creates an accessor and reader for the field.
        # Options:
        #   :internal_name => allows the specification of an internal field name differing from the API's field name.
        #   :api_name => allows the API name to be specified if it can't be properly converted from camelize.
        #   :model_name => allows class used for children to be different from it's ndoe name in the XML.
        #   :type => type of field
        def define_simple_attribute(field_name, field_type, options)
          self.fields ||= {}
          
          internal_field_name = options[:internal_name] || field_name
          self.fields[field_name] = options.merge({
            :internal_name  => internal_field_name, 
            :api_name       => options[:api_name] || field_name.to_s.camelize,
            :type           => field_type
          })
          define_method internal_field_name do 
            @attributes[field_name]
          end
          define_method "#{internal_field_name}=".to_sym do | value | 
            @attributes[field_name] = value
          end
        end
        
      end
      
    end
  end
end