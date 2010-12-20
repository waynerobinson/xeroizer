module Xeroizer
  module Record
    
    class BaseModel
      
      include ClassLevelInheritableAttributes
      inheritable_attributes :api_controller_name
      
      class InvaidPermissionError < StandardError; end
      ALLOWED_PERMISSIONS = [:read, :write, :update]
      inheritable_attributes :permissions
      @permissions = {}

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
        
        # Set the permissions allowed for this class type.
        # There are no permissions set by default.
        # Valid permissions are :read, :write, :update.
        def set_permissions(*args)
          self.permissions = {}
          args.each do | permission |
            raise InvaidPermissionError.new("Permission #{permission} is invalid.") unless ALLOWED_PERMISSIONS.include?(permission)
            self.permissions[permission] = true
          end
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
        
        def http_get(extra_params = {})
          application.http_get(application.client, url, extra_params)
        end
        
        def http_put(xml, extra_params = {})
          application.http_put(application.client, url, xml, extra_params)
        end

        def http_post(xml, extra_params = {})
          application.http_post(application.client, url, xml, extra_params)
        end
        
        # Build a record with attributes set to the value of attributes.
        def build(attributes = {})
          Xeroizer::Record.const_get(model_name.to_sym).build(attributes, self)
        end
        
        # Retreive full record list for this model. 
        def all(options = {})
          raise MethodNotAllowed.new(self, :all) unless self.class.permissions[:read]
          response_xml = http_get(options)
          parse_response(response_xml, options)
        end
        
        # Helper method to retrieve just the first element from
        # the full record list.
        def first(options = {})
          raise MethodNotAllowed.new(self, :all) unless self.class.permissions[:read]
          result = all(options)
          result.first if result.is_a?(Array)
        end
        
        # Retrieve record matching the passed in ID.
        def find(id, options = {})
          raise MethodNotAllowed.new(self, :all) unless self.class.permissions[:read]
          response_xml = @application.http_get(@application.client, "#{url}/#{CGI.escape(id)}", options)
          result = parse_response(response_xml, options)
          result = result.first if result.is_a?(Array)
          result.complete_record_downloaded = true
          result
        end
        
        # Parse the response retreived during any request.
        def parse_response(raw_response, request = {}, options = {})
          @response = Xeroizer::Response.new
          @response.response_xml = raw_response
          
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
        
      protected
      
        
        # Parse the records part of the XML response and builds model instances as necessary.
        def parse_records(elements)
          @response.response_items = []
          elements.each do | element |
            @response.response_items << Xeroizer::Record.const_get(model_name.to_sym).build_from_node(element, self)
          end
        end
        
    end
    
  end
end