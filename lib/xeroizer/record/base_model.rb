require 'xeroizer/record/base_model_http_proxy'

module Xeroizer
  module Record

    class BaseModel

      include ClassLevelInheritableAttributes
      class_inheritable_attributes :api_controller_name

      module InvaidPermissionError; end
      class InvalidPermissionError < StandardError
        include InvaidPermissionError
      end
      ALLOWED_PERMISSIONS = [:read, :write, :update]
      class_inheritable_attributes :permissions

      class_inheritable_attributes :xml_root_name
      class_inheritable_attributes :optional_xml_root_name
      class_inheritable_attributes :xml_node_name

      DEFAULT_RECORDS_PER_BATCH_SAVE = 50

      include BaseModelHttpProxy

      attr_reader :application
      attr_reader :model_name
      attr :model_class
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

        # Retreive full record list for this model.
        def all(options = {})
          raise MethodNotAllowed.new(self, :all) unless self.class.permissions[:read]
          response_xml = http_get(parse_params(options))
          response = parse_response(response_xml, options)
          response.response_items || []
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
          response = parse_response(response_xml, options)
          result = response.response_items.first if response.response_items.is_a?(Array)
          result.complete_record_downloaded = true if result
          result
        end

        def save_records(records, chunk_size = DEFAULT_RECORDS_PER_BATCH_SAVE)
          no_errors = true
          return false unless records.all?(&:valid?)

          actions = records.group_by {|o| o.new_record? ? create_method : :http_post }
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
          Response.parse(response_xml, options) do | response, elements, response_model_name |
            if model_name == response_model_name
              @response = response
              parse_records(response, elements, paged_records_requested?(options))
            end
          end
        end

        def create_method
          :http_put
        end

      protected


        def paged_records_requested?(options)
          options.has_key?(:page) and options[:page].to_i >= 0
        end


      # Parse the records part of the XML response and builds model instances as necessary.
        def parse_records(response, elements, paged_results)
          elements.each do | element |
            new_record = model_class.build_from_node(element, self)
            if element.attribute('status').try(:value) == 'ERROR'
              new_record.errors = []
              element.xpath('.//ValidationError').each do |err|
                new_record.errors << err.text.gsub(/^\s+/, '').gsub(/\s+$/, '')
              end
            end
            new_record.paged_record_downloaded = paged_results
            response.response_items << new_record
          end
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
