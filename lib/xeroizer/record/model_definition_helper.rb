module Xeroizer
  module Record
    module ModelDefinitionHelper
      
      def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
      end
      
      module ClassMethods

        # Possible primary keys. At least one of these must exist before attempting to update a record.
        def set_possible_primary_keys(*args)
          args = [args] unless args.is_a?(Array)
          self.possible_primary_keys = args
        end
        
        # Set the actual Xero primary key for this record.
        def set_primary_key(primary_key_name)
          self.primary_key_name = primary_key_name
        end
        
        # Whether this record type's list results contain summary data only.
        #
        # Records like invoices, when returning a list, only show summary data for
        # certain types of associations (like the contact record) and do not return
        # any data for line items.
        #
        # Default: false
        def list_contains_summary_only(status)
          self.summary_only = status
        end
        
        def list_contains_summary_only?
          !!summary_only
        end
              
        # Helper methods used to define the fields this model has.
        def string(field_name, options = {});     define_simple_attribute(field_name, :string, options); end
        def boolean(field_name, options = {});    define_simple_attribute(field_name, :boolean, options); end
        def integer(field_name, options = {});    define_simple_attribute(field_name, :integer, options, 0); end
        def decimal(field_name, options = {});    define_simple_attribute(field_name, :decimal, options, 0.0); end
        def date(field_name, options = {});       define_simple_attribute(field_name, :date, options); end
        def datetime(field_name, options = {});   define_simple_attribute(field_name, :datetime, options); end
        def datetime_utc(field_name, options = {});   define_simple_attribute(field_name, :datetime_utc, options); end
        
        def guid(field_name, options = {})
          # Ensure all automated Id conversions are changed to ID.
          options[:api_name] ||= field_name.to_s.camelize.gsub(/Id/, 'ID')
          define_simple_attribute(field_name, :guid, options)
        end
              
        # Helper method to simplify field definition. 
        # Creates an accessor and reader for the field.
        # Options:
        #   :internal_name => allows the specification of an internal field name differing from the API's field name.
        #   :api_name => allows the API name to be specified if it can't be properly converted from camelize.
        #   :model_name => allows class used for children to be different from it's ndoe name in the XML.
        #   :type => type of field
        #   :skip_writer => skip the writer method
        def define_simple_attribute(field_name, field_type, options, value_if_nil = nil)
          self.fields ||= {}
          
          internal_field_name = options[:internal_name] || field_name
          self.fields[field_name] = options.merge({
            :internal_name  => internal_field_name, 
            :api_name       => options[:api_name] || field_name.to_s.camelize,
            :type           => field_type
          })
          define_method internal_field_name do 
            @attributes[field_name].nil? ? value_if_nil : @attributes[field_name]
          end
          
          unless options[:skip_writer]
            define_method "#{internal_field_name}=".to_sym do | value | 
              parent.mark_dirty(self) if parent
              @attributes[field_name] = value
            end
          end
        end
        
      end
      
      module InstanceMethods
        
        # Returns the value of the Xero primary key for this record if it exists.
        def id
          self[self.class.primary_key_name]
        end

        # Sets the value of the Xero primary key for this record if it exists.
        def id=(new_id)
          parent.mark_dirty(self) if parent
          self[self.class.primary_key_name] = new_id
        end
        
      end
      
    end
  end
end
