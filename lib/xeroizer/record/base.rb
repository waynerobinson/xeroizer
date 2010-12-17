module Xeroizer
  module Record
    
    class Base
      
      include ClassLevelInheritableAttributes
      inheritable_attributes :fields, :possible_primary_keys
      @fields = {}
      @possible_primary_keys = []
                 
      attr_reader :attributes
      attr_accessor :new_record
      attr_reader :parent
      
      class << self
                
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
        
        # Helper method to simplify field definition. 
        # Creates an accessor and reader for the field.
        # Options:
        #   :internal_name => allows the specification of an internal field name differing from the API's field name.
        #   :api_name => allows the API name to be specified if it can't be properly converted from camelize.
        #   :model_name => allows class used for children to be different from it's ndoe name in the XML.
        #   :type => type of field
        def define_simple_attribute(field_name, field_type, options)
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
        
        # Build a record instance from the XML node.
        def build_from_node(node, parent)
          record = new(parent)
          record.new_record = false
          node.elements.each do | element |
            field = self.fields[element.name.to_s.underscore.to_sym]
            if field
              record.send("#{field[:internal_name]}=", case field[:type]
                when :string      then element.text
                when :boolean     then (element.text == 'true')
                when :integer     then element.text.to_i
                when :decimal     then BigDecimal.new(element.text)
                when :date        then Date.parse(element.text)
                when :datetime    then Time.parse(element.text)
                when :belongs_to  then Xeroizer::Record.const_get(element.name.to_sym).build_from_node(element, parent)
                when :has_many
                  sub_field_name = field[:model_name] ? field[:model_name].to_sym : element.children.first.name.to_sym
                  sub_parent = record.new_model_class(sub_field_name)
                  element.children.inject([]) do | list, element |
                    list << Xeroizer::Record.const_get(sub_field_name).build_from_node(element, sub_parent)
                  end
                        
              end)
            end
          end
          
          record
        end
        
        # Build a record with attributes set to the value of attributes.
        def build(attributes, parent)
          record = new(parent)
          attributes.each do | key, value |
            record.send("#{key}=".to_sym, value)
          end
          record
        end
        
      end
      
      
      public
      
        def initialize(parent)
          @parent = parent
          @attributes = {}
          @new_record = true
        end
        
        def [](attribute)
          self.send(attribute)
        end
        
        def []=(attribute, value)
          self.send("#{attribute}=", value)
        end
        
        def new_record?
          !!@new_record
        end
        
        def save
          if new_record?
            create
          else
            update
          end
        end
        
        def to_xml(b = Builder::XmlMarkup.new(:indent => 2))
          b.tag!(parent.model_name) { 
            attributes.each do | key, value |
              unless value.nil?
                field = self.class.fields[key]
                xml_value_from_field(b, field, value)
              end
            end
          }
        end
        
        def new_model_class(model_name)
          Xeroizer::Record.const_get("#{model_name}Model".to_sym).new(parent.application, model_name.to_s)
        end
                
      protected
      
        # Attempt to create a new record.
        def create
          parse_save_response(parent.http_put(to_xml))
        end
        
        # Attempt to update an existing record.
        def update
          if self.class.possible_primary_keys.all? { | possible_key | self[possible_key].nil? }
            raise RecordKeyMustBeDefined.new(self.class.possible_primary_keys)
          end
          
          parse_save_response(parent.http_post(to_xml))
        end
        
        # Parse the response from a create/update request.
        def parse_save_response(response_xml)
          record = parent.parse_response(response_xml)
          record = record.first if record.is_a?(Array)
          if record && record.is_a?(self.class)
            @attributes = record.attributes
            @new_record = false
          end
          self
        end
        
        # Format a attribute for use in the XML passed to Xero.
        def xml_value_from_field(b, field, value)
          case field[:type]
            when :string      then b.tag!(field[:api_name], value)
            when :boolean     then b.tag!(field[:api_name], value ? 'true' : 'false')
            when :integer     then b.tag!(field[:api_name], value.to_i)
            when :decimal   
              real_value = case value
                when BigDecimal   then value.to_s('F')
                when String       then BigDecimal.new(value).to_f('F')
                else              value
              end
              b.tag!(field[:api_name], real_value)
              
            when :date        then b.tag!(field[:api_name], value.utc.strftime("%Y-%m-%d"))
            when :datetime    then b.tag!(field[:api_name], value.utc.strftime("%Y-%m-%dT%H:%M:%S"))
            when :belongs_to  
              value.to_xml(b)
              nil
              
            when :has_many    
              if value.size > 0
                b.tag!(value.first.parent.model_name.pluralize) {
                  value.each { | record | record.to_xml(b) }
                }
                nil
              end
            
          end
        end
             
    end
    
  end
end