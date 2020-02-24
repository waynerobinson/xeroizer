require 'xeroizer/record/model_definition_helper'
require 'xeroizer/record/record_association_helper'
require 'xeroizer/record/validation_helper'
require 'xeroizer/record/xml_helper'
require 'xeroizer/logging'
require 'active_support/inflector'

module Xeroizer
  module Record

    class Base

      include ClassLevelInheritableAttributes
      class_inheritable_attributes :fields, :possible_primary_keys, :primary_key_name, :summary_only, :validators

      attr_reader :attributes
      attr_reader :parent
      attr_reader :model
      attr_accessor :errors
      attr_accessor :complete_record_downloaded

      attr_writer :api_method_for_creating
      attr_writer :api_method_for_updating

      attr_accessor :paged_record_downloaded
      attr_accessor :after_initialize

      include ModelDefinitionHelper
      include RecordAssociationHelper
      include ValidationHelper
      include XmlHelper

      class << self

        # Build a record with attributes set to the value of attributes.
        def build(attributes, parent)
          record = new(parent)
          attributes.each do | key, value |
            attr_to_set = if record.respond_to?("#{key}=")
              key
            elsif record.class.fields.key?(key)
              record.class.fields[key][:internal_name]
            end
            record.send("#{attr_to_set}=", value) if attr_to_set
          end
          record
        end

      end

      public

        def initialize(parent)
          @parent = parent
          @model = new_model_class(self.class.name.demodulize)
          @attributes = {}
        end

        def new_model_class(model_name)
          Xeroizer::Record.const_get("#{model_name}Model".to_sym).new(parent.try(:application), model_name.to_s)
        end

        def [](attribute)
          self.send(attribute)
        end

        def []=(attribute, value)
          parent.mark_dirty(self) if parent
          self.send("#{attribute}=".to_sym, value)
        end

        def non_calculated_attributes
          attributes.reject {|name| self.class.fields[name][:calculated] }
        end

        def attributes=(new_attributes)
          return unless new_attributes.is_a?(Hash)
          parent.mark_dirty(self) if parent
          new_attributes.each do | key, value |
            attr = respond_to?("#{key}=") ? key : self.class.fields[key][:internal_name]
            self.send("#{attr}=", value)
          end
        end

        def update_attributes(attributes)
          self.attributes = attributes
          save
        end

        def new_record?
          id.nil?
        end

        # Check to see if the complete record is downloaded.
        def complete_record_downloaded?
          if !!self.class.list_contains_summary_only?
            !!complete_record_downloaded
          else
            true
          end
        end


        def paged_record_downloaded?
          !!paged_record_downloaded
        end

        # Downloads the complete record if we only have a summary of the record.
        def download_complete_record!
          record = self.parent.find(self.id)
          @attributes = record.attributes if record
          @complete_record_downloaded = true
          parent.mark_clean(self)
          self
        end

        def save
          save!
          true
        rescue XeroizerError => e
          log "[ERROR SAVING] (#{__FILE__}:#{__LINE__}) - #{e.message}"
          false
        end

        def save!
          raise RecordInvalid unless valid?
          if new_record?
            create
          else
            update
          end

          saved!
        end

        def saved!
          @complete_record_downloaded = true
          parent.mark_clean(self)
          true
        end

        def to_json(*args)
          to_h.to_json(*args)
        end

        # Deprecated
        def as_json(options = {})
          to_h.to_json
        end

        def to_h
          attrs = self.attributes.reject {|k, v| k == :parent }.map do |k, v|
            [k, v.kind_of?(Array) ? v.map(&:to_h) : (v.respond_to?(:to_h) ? v.to_h : v)]
          end
          Hash[attrs]
        end

        def inspect
          attribute_string = self.attributes.collect do |attr, value|
            "#{attr.inspect}: #{value.inspect}"
          end.join(", ")
          "#<#{self.class} #{attribute_string}>"
        end

        # TODO Is this necessary with parent.create?
        def api_method_for_creating
          @api_method_for_creating || parent.create || :http_put
        end
        def api_method_for_updating
          @api_method_for_updating || :http_post
        end

      protected
      
        # Attempt to create a new record.
        def create
          request = json? ? to_api_json : to_xml
          log "[CREATE SENT] (#{__FILE__}:#{__LINE__}) #{request}"

          response = parent.send(api_method_for_creating, request, extra_params_for_create_or_update)
          log "[CREATE RECEIVED] (#{__FILE__}:#{__LINE__}) #{response}"

          parse_save_response(response)
        end

        # Attempt to update an existing record.
        def update
          if self.class.possible_primary_keys && self.class.possible_primary_keys.all? { | possible_key | self[possible_key].nil? }
            raise RecordKeyMustBeDefined.new(self.class.possible_primary_keys)
          end

          request = json? ? to_api_json : to_xml
          log "[UPDATE SENT] (#{__FILE__}:#{__LINE__}) \r\n#{request}"

          response = parent.send(api_method_for_updating, request, extra_params_for_create_or_update)

          log "[UPDATE RECEIVED] (#{__FILE__}:#{__LINE__}) \r\n#{response}"

          parse_save_response(response)
        end

        def extra_params_for_create_or_update
          json? ? {raw_body: true, content_type: "application/json", url: api_url} : {}
        end

        def api_url; end # individual models can override this

        def to_api_json
          attrs = self.attributes.reject {|k, v| k == :parent }.map do |k, v|
            value = if v.respond_to?(:to_api_json)
              v.to_api_json
            elsif k == :periods # hack for leave request periods for xero uk
              v.map(&:to_api_json)
            elsif v.is_a?(Array) && [0, 1].include?(v.count)
              v.first # hack for timesheet line has_array values
            else
              v
            end
            [k.to_s.camelize(:lower), value]
          end
          Hash[attrs].to_json
        end

        def json?
          parent.application.api_format == :json
        end

        # Parse the response from a create/update request.
        def parse_save_response(response_xml)
          response = parent.parse_response(response_xml)
          record = response.response_items.first if response.response_items.is_a?(Array)
          if record && record.is_a?(self.class)
            @attributes = record.attributes
          end
          self
        end

        def log(what)
          Xeroizer::Logging::Log.info what
        end

    end

  end
end
