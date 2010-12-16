module Xeroizer
  module Record
    
    class BaseClass
      
      include ClassLevelInheritableAttributes
      inheritable_attributes :api_controller_name

      attr_reader :application
      attr_reader :model_name
      attr_reader :response
      
      class << self
        
        # Method to allow override of the default controller name used 
        # in the API URLs. 
        #
        # Default: pluaralized model name (e.g. if the controller name is
        # Invoice then the default is Invoices.
        def set_api_controller_name(controller_name)
          self.api_controller_name = controller_name
        end
        
      end
            
      public
        
        def initialize(application, model_name)
          @application = application
          @model_name = model_name
        end
        
        # Retrieve the controller name.
        #
        # Default: pluaralized model name (e.g. if the controller name is
        # Invoice then the default is Invoices.
        def api_controller_name
          self.class.api_controller_name || model_name.pluralize
        end

        # URL end-point for this model.
        def url
          @application.xero_url + '/' + api_controller_name
        end
        
        # Retreive full record list for this model. 
        def all(options = {})
          response_xml = @application.http_get(@application.client, "#{url}", options)
          parse_response(response_xml, options)
        end
        
        # Helper method to retrieve just the first element from
        # the full record list.
        def first(options = {})
          result = all(options)
          result.first if result.is_a?(Array)
        end
        
        # Retrieve record matching the passed in ID.
        def find(id, options = {})
          response_xml = @application.http_get(@application.client, "#{url}/#{CGI.escape(id)}", options)
          puts response_xml
          result = parse_response(response_xml, options)
          result.first if result.is_a?(Array)
        end
                
      protected
      
        # Parse the response retreived during any request.
        def parse_response(raw_response, request = {}, options = {})
          @response = Xeroizer::Response.new
          
          doc = Nokogiri::XML(raw_response) { | cfg | cfg.noblanks }
          
          # check for responses we don't understand
          raise Xeroizer::UnparseableResponse.new(doc.root.name) unless doc.root.name == 'Response'
          
          doc.root.elements.each do | element |
                        
            # Text element
            if element.children && element.children.size == 1 && element.children.first.text?
              case element.name
                when 'Id'           then @response.id = element.text
                when 'Status'       then @response.status = element.text
                when 'ProviderName' then @response.provider = element.text
                when 'DateTimeUTC'  then @response.date_time = Time.parse(element.text)
              end
              
            # Records in response
            elsif element.children && element.children.size > 0 && element.children.first.name == model_name
              parse_records(element.children)
            end
          end
          
          @response.response_items
        end
        
        # Parse the records part of the XML response and builds model instances as necessary.
        def parse_records(elements)
          @response.response_items = []
          elements.each do | element |
            @response.response_items << Xeroizer::Record.const_get(model_name.to_sym).build_from_node(element, self)
          end
        end
        
    end
    
    class Base
     
      include ClassLevelInheritableAttributes
      inheritable_attributes :fields
      @fields = {}
     
      attr_reader :attributes
      attr_reader :model_class
      
      class << self
        
        # Helper methods used to define the fields this model has.
        def string(field_name, options = {});     define_simple_attribute(field_name, :string, options); end
        def boolean(field_name, options = {});    define_simple_attribute(field_name, :boolean, options); end
        def integer(field_name, options = {});    define_simple_attribute(field_name, :integer, options); end
        def decimal(field_name, options = {});    define_simple_attribute(field_name, :decimal, options); end
        def date(field_name, options = {});       define_simple_attribute(field_name, :date, options); end
        def datetime(field_name, options = {});   define_simple_attribute(field_name, :datetime, options); end
        def belongs_to(field_name, options = {}); define_simple_attribute(field_name, :belongs_to, options); end
        def has_many(field_name, options = {});   define_simple_attribute(field_name, :has_many, options); end
        
        # Helper method to simplify field definition. 
        # Creates an accessor and reader for the field.
        # Options:
        #   :internal_name => allows the specification of an internal field name differing from the API's field name.
        #   :model_name => allows class used for children to be different from it's ndoe name in the XML.
        #   :type => type of field
        def define_simple_attribute(field_name, field_type, options)
          internal_field_name = options[:internal_name] || field_name
          self.fields[field_name] = options.merge(:internal_name => internal_field_name, :type => field_type)
          define_method internal_field_name do 
            @attributes[field_name]
          end
          define_method "#{internal_field_name}=".to_sym do | value | 
            @attributes[field_name] = value
          end
        end
        
        # Build a record instance from the XML node.
        def build_from_node(node, model_class)
          record = new(model_class)
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
                when :belongs_to  then Xeroizer::Record.const_get(element.name.to_sym).build_from_node(element, model_class)
                when :has_many    
                  element.children.inject([]) do | list, element |
                    list << Xeroizer::Record.const_get(field[:model_name] ? field[:model_name].to_sym : element.name.to_sym).build_from_node(element, model_class)
                  end
                        
              end)
            end
          end
          
          record
        end
        
      end
      
      
      public
      
        def initialize(model_class)
          @model_class = model_class
          @attributes = {}
        end
     
    end
    
  end
end