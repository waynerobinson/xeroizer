require 'xeroizer/record/base_model_http_proxy'
require 'active_support/inflector'

module Xeroizer
  module Record

    class BaseModel

      include ClassLevelInheritableAttributes
      class_inheritable_attributes :api_controller_name

      module InvaidPermissionError; end
      class InvalidPermissionError < XeroizerError
        include InvaidPermissionError
      end
      ALLOWED_PERMISSIONS = [:read, :write, :update]
      class_inheritable_attributes :permissions

      class_inheritable_attributes :xml_root_name
      class_inheritable_attributes :optional_xml_root_name
      class_inheritable_attributes :xml_node_name

      DEFAULT_RECORDS_PER_BATCH_SAVE = 50

      class_inheritable_attributes :standalone_model
      class_inheritable_attributes :before_padding
      class_inheritable_attributes :after_padding

      include BaseModelHttpProxy

      attr_reader :application
      attr_reader :model_name
      attr_writer :model_class
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
            raise InvalidPermissionError.new("Permission #{permission} is invalid.") unless ALLOWED_PERMISSIONS.include?(permission)
            self.permissions[permission] = true
          end
        end

        # Method to allow override of the default XML node name.
        #
        # Default: singularized model name in camel-case.
        def set_xml_node_name(node_name)
          self.xml_node_name = node_name
        end

        # Method to allow override of the default XML root name to use
        # in has_many associations.
        def set_xml_root_name(root_name)
          self.xml_root_name = root_name
        end

        # Method to add an extra top-level node to use in has_many associations.
        def set_optional_xml_root_name(optional_root_name)
          self.optional_xml_root_name = optional_root_name
        end

        # Usually the xml structure will be <Classes><Class><Subclasses><Subclass></Subclass></Subclasses></Class></Classes>
        # If this is true, the <Class> tag isn't expected. So it would be
        # <Classes><Subclasses><Subclass></Subclass></Subclasses></Classes>
        # Example: http://developer.xero.com/payroll-api/PayItems/#GET
        def set_standalone_model(boolean)
          self.standalone_model = boolean
        end

        # Usually the xml structure will be <Response><Payslips><Payslip><xx></xx></Payslip></Payslips></Response>
        # Provide wrapping if the response is <Response><Payslip><xx></xx></Payslip></Response>
        def set_api_response_padding(padding)
          self.before_padding = "<#{padding.pluralize}><#{padding}>"
          self.after_padding = "</#{padding}></#{padding.pluralize}>"
        end

        def pad_api_response?
          self.before_padding && self.after_padding
        end

      end

      public

      def initialize(application, model_name)
        @application = application
        @model_name = model_name
        @allow_batch_operations = false
        @objects = {}
      end

      # Retrieve the controller name.
      #
      # Default: pluaralized model name (e.g. if the controller name is
      # Invoice then the default is Invoices.
      def api_controller_name
        self.class.api_controller_name || model_name.pluralize
      end

      def model_class
        @model_class ||= Xeroizer::Record.const_get(model_name.to_sym)
      end

      # Build a record with attributes set to the value of attributes.
      def build(attributes = {})
        model_class.build(attributes, self).tap do |resource|
          mark_dirty(resource)
        end
      end

      def mark_dirty(resource)
        if @allow_batch_operations
          @objects[model_class] ||= {}
          @objects[model_class][resource.object_id] ||= resource
        end
      end

      def mark_clean(resource)
        if @objects and @objects[model_class]
          @objects[model_class].delete(resource.object_id)
        end
      end

      # Create (build and save) a record with attributes set to the value of attributes.
      def create(attributes = {})
        build(attributes).tap { |resource| resource.save }
      end

      # Retrieve full record list for this model.
      def all(options = {})
        raise MethodNotAllowed.new(self, :all) unless self.class.permissions[:read]
        response_xml = http_get(parse_params(options))
        response = parse_response(response_xml, options)
        response.response_items || []
      end

      # allow invoices to be process in batches of 100 as per xero documentation
      # https://developer.xero.com/documentation/api/invoices/
      def find_in_batches(options = {}, &block)
        options[:page] ||= 1
        while results = all(options)
          if results.any?
            yield results
            options[:page] += 1
          else
            break
          end
        end
      end

      # Helper method to retrieve just the first element from
      # the full record list.
      def first(options = {})
        raise MethodNotAllowed.new(self, :all) unless self.class.permissions && self.class.permissions[:read]
        result = all(options)
        result.first if result.is_a?(Array)
      end

      # Retrieve record matching the passed in ID.
      def find(id, options = {})
        raise MethodNotAllowed.new(self, :all) unless self.class.permissions && self.class.permissions[:read]
        response_xml = @application.http_get(@application.client, "#{url}/#{CGI.escape(id)}", options)
        response = parse_response(response_xml, options)
        result = response.response_items.first if response.response_items.is_a?(Array)
        result.complete_record_downloaded = true if result
        result
      end

      def save_records(records, chunk_size = DEFAULT_RECORDS_PER_BATCH_SAVE)
        no_errors = true
        return false unless records.all?(&:valid?)

        actions = records.group_by {|o| o.new_record? ? o.api_method_for_creating : o.api_method_for_updating }
         actions.each_pair do |http_method, records_for_method|
           records_for_method.each_slice(chunk_size) do |some_records|
            request = to_bulk_xml(some_records)
            response = parse_response(self.send(http_method, request, {:summarizeErrors => false}))
            response.response_items.each_with_index do |record, i|
              if record and record.is_a?(model_class)
                some_records[i].attributes = record.non_calculated_attributes
                some_records[i].errors = record.errors
                no_errors = record.errors.nil? || record.errors.empty? if no_errors
                some_records[i].saved!
              end
            end
          end
        end

        no_errors
      end

      def batch_save(chunk_size = DEFAULT_RECORDS_PER_BATCH_SAVE)
        @objects = {}
        @allow_batch_operations = true

        begin
          yield

          if @objects[model_class]
            objects = @objects[model_class].values.compact
            save_records(objects, chunk_size)
          end
        ensure
          @objects = {}
          @allow_batch_operations = false
        end
      end

      def parse_response(response_xml, options = {})
        format = options[:api_format] || @application.api_format
        case format
        when :json
          parse_json_response(response_body, options)
        else
          parse_xml_response(response_body, options)
        end
      end

      protected
        def parse_json_response(response_body, options = {})
          json = ::JSON.parse(response_body)
          response = Response.new

          model_name_to_parse =
           if self.respond_to?(:model_name_to_parse)
             self.model_name_to_parse
           else
             self.model_name
           end

          iterable = json[model_name_to_parse.camelize(:lower).pluralize] || json[model_name_to_parse.camelize(:lower)]
          iterable = [iterable] if iterable.is_a?(Hash)

          iterable.each {|object|
            object = object.map {|key, value| [key.underscore.to_sym, value]}.to_h
            response_object = self.model_class.build(object, self)
            self.model_class.fields.each {|field, field_props|
              if field_props[:type] == :has_many && object[field]
                response_object[field] = []
                object[field].each {|child_object|
                  model_class_name = field_props[:api_child_name].to_sym # TimesheetLine
                  model_klass_obj = response_object.new_model_class(model_class_name)
                  response_object[field] << model_klass_obj.model_class.build(child_object.map {|key, value| [key.underscore.to_sym, value]}.to_h, model_klass_obj)
                }
              end
            }
            response.response_items << response_object
          }

          response
        end

        def parse_xml_response(response_body, options = {})
          Response.parse(response_body, options) do | response, elements, response_model_name |
            if self.class.pad_api_response?
              @response = response
              parse_records(response, Nokogiri::XML("#{self.class.before_padding}#{elements.to_xml}#{self.class.after_padding}").root.elements, paged_records_requested?(options), (options[:base_module] || Xeroizer::Record))
            elsif model_name == response_model_name
              @response = response
              parse_records(response, elements, paged_records_requested?(options), (options[:base_module] || Xeroizer::Record))
            elsif self.class.standalone_model && self.class.xml_root_name == elements.first.parent.name
              @response = response
              parse_records(response, elements, paged_records_requested?(options), (options[:base_module] || Xeroizer::Record), true)
            end
          end
        end
      end
      protected

      def create_method
        :http_put
      end

      def paged_records_requested?(options)
        options.has_key?(:page) and options[:page].to_i >= 0
      end

      # Parse the records part of the XML response and builds model instances as necessary.
      def parse_records(response, elements, paged_results, base_module, standalone_model = false)
        elements.each do | element |
          new_record = model_class.build_from_node(element, self, base_module, standalone_model)
          if element.attribute('status').try(:value) == 'ERROR'
            new_record.errors = []
            element.xpath('.//ValidationError').each do |err|
              new_record.errors << err.text.gsub(/^\s+/, '').gsub(/\s+$/, '')
            end
          end

          if standalone_model
            if response.response_items.count == 0
              new_record.paged_record_downloaded = paged_results
            else
              # http://developer.xero.com/documentation/payroll-api/settings/
              # tracking categories have subcategories of timesheet categoires and employee groups
              # which we group together here as it's much easier to model
              fields_to_fill = model_class.fields.find_all do |f|
                new_record_field = new_record[f[0]]
                if new_record_field.respond_to?(:count)
                  new_record_field.count > 0
                else
                  !new_record_field.nil?
                end
              end
              fields_to_fill.each {|field| response.response_items.first[field[0]] = new_record[field[0]]}
            end
          else
            new_record.paged_record_downloaded = paged_results
          end
          response.response_items << new_record
        end
        response.response_items
      end

      def to_bulk_xml(records, builder = Builder::XmlMarkup.new(:indent => 2))
        tag = (self.class.optional_xml_root_name || model_name).pluralize
        builder.tag!(tag) do
          records.each {|r| r.to_xml(builder) }
        end
      end

      # Parse the response from a create/update request.
      def parse_save_response(response_xml)
        response = parse_response(response_xml)
        record = response.response_items.first if response.response_items.is_a?(Array)
        if record && record.is_a?(self.class)
          @attributes = record.attributes
        end
        self
      end
    end

  end
end
