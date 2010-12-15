module Xeroizer
  module Record
    
    class BaseClass

      attr_reader :application
      attr_reader :model_name
      attr_reader :response
            
      public
        
        def initialize(application, model_name)
          @application = application
          @model_name = model_name
        end
        
        def url
          @application.xero_url + '/' + model_name
        end
        
        def all(options = {})
          response_xml = @application.http_get(@application.client, "#{url}", options)
          parse_response(response_xml, options)
        end
        
        def first(options = {})
          result = all(options)
          result.first if result.is_a?(Array)
        end
        
        def find(id, options = {})
          response_xml = @application.http_get(@application.client, "#{url}/#{CGI.escape(id)}", options)
          puts response_xml
          result = parse_response(response_xml, options)
          result.first if result.is_a?(Array)
        end
                
      protected
      
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
        
        def parse_records(elements)
          @response.response_items = []
          elements.each do | element |
            @response.response_items << Xeroizer::Record.const_get(model_name.to_sym).build_from_node(element)
          end
        end
        
    end
    
    class Base
     
      attr_reader :attributes
      @@fields = {}
      
      class << self
        
        def string(field_name);     define_simple_attribute(field_name, :string); end
        def boolean(field_name);    define_simple_attribute(field_name, :boolean); end
        def decimal(field_name);    define_simple_attribute(field_name, :decimal); end
        def datetime(field_name);   define_simple_attribute(field_name, :datetime); end
        def belongs_to(field_name); define_simple_attribute(field_name, :belongs_to); end
        def has_many(field_name);   define_simple_attribute(field_name, :has_many); end
        
        def define_simple_attribute(field_name, field_type)
          @@fields[field_name] = field_type
          define_method field_name do 
            @attributes[field_name]
          end
          define_method "#{field_name}=".to_sym do | value | 
            @attributes[field_name] = value
          end
        end
        
        def build_from_node(node)
          record = new
          node.elements.each do | element |
            internal_name = element.name.to_s.underscore.to_sym
            if @@fields[internal_name]
              record.attributes[internal_name] = case @@fields[internal_name]
                when :string      then element.text
                when :boolean     then (element.text == 'true')
                when :decimal     then BigDecimal.new(element.text)                  
                when :datetime    then Time.parse(element.text)
                when :belongs_to  then Xeroizer::Record.const_get(element.name.to_sym).build_from_node(element)
                when :has_many    
                  record_list = []
                  element.children.each do | element |
                    record_list << Xeroizer::Record.const_get(element.name.to_sym).build_from_node(element)
                  end
                  record_list
                        
              end
            end
          end
          
          record
        end
        
      end
      
      
      public
      
        def initialize
          @attributes = {}
        end
     
    end
    
  end
end