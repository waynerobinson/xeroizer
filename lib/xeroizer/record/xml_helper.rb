require 'active_support/time'

module Xeroizer
  module Record
    module XmlHelper

      def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
      end

      module ClassMethods

        # Build a record instance from the XML node.
        def build_from_node(node, parent, base_module, standalone_model = false)
          record = new(parent)
          node.elements.each do | element |
            element_name = standalone_model ? element.name.to_s.pluralize : element.name.to_s
            field = self.fields[element_name.underscore.to_sym]
            if field
              value = case field[:type]
                when :guid        then element.text
                when :string      then element.text
                when :boolean     then (element.text == 'true')
                when :integer     then element.text.to_i
                when :decimal     then BigDecimal(element.text)
                when :date        then Date.parse(element.text)
                when :datetime    then Time.parse(element.text)
                when :datetime_utc then ActiveSupport::TimeZone['UTC'].parse(element.text).utc
                when :belongs_to
                  model_name = field[:model_name] ? field[:model_name].to_sym : element.name.to_sym
                  base_module.const_get(model_name).build_from_node(element, parent, base_module)

                when :has_many
                  if element.element_children.size > 0
                    sub_field_name = field[:model_name] ? field[:model_name].to_sym : (standalone_model ? element.name : element.children.first.name).to_sym
                    sub_parent = record.new_model_class(sub_field_name)

                    if standalone_model
                      base_module.const_get(sub_field_name).build_from_node(element, sub_parent, base_module)
                    else
                      remove_empty_text_nodes(element.children).inject([]) do | list, inner_element |
                        list << base_module.const_get(sub_field_name).build_from_node(inner_element, sub_parent, base_module)
                      end
                    end
                  else
                    []
                  end

                when :has_array
                  if element.element_children.size > 0
                    sub_field_name = field[:model_name] ? field[:model_name].to_sym : element.children.first.name.to_sym
                    sub_parent = record.new_model_class(sub_field_name)
                    element.element_children.inject([]) do |list, child|
                      list << base_module.const_get(sub_field_name).build_from_node(child, sub_parent, base_module)
                    end
                  else
                    []
                  end

              end
              if field[:calculated]
                record.attributes[field[:internal_name]] = value
              elsif standalone_model
                record.send("add_#{field[:internal_name].to_s.singularize}".to_sym, value)
              else
                record.send("#{field[:internal_name]}=".to_sym, value)
              end
            end
          end

          # special case for array models eg. NumberOfUnit(s) in http://developer.xero.com/documentation/payroll-api/timesheets/
          if node.elements.empty? && parent.is_a?(Xeroizer::Record::PayrollArrayBaseModel)
            field = self.fields[:value]
            if field
              element = node.children.first
              value = case field[:type]
                when :guid        then element.text
                when :string      then element.text
                when :boolean     then (element.text == 'true')
                when :integer     then element.text.to_i
                when :decimal     then BigDecimal(element.text)
                when :date        then Date.parse(element.text)
                when :datetime    then Time.parse(element.text)
                when :datetime_utc then ActiveSupport::TimeZone['UTC'].parse(element.text).utc
              end

              record.value = value
            end
          end

          parent.mark_clean(record)
          record
        end

        private
        def remove_empty_text_nodes(children)
          children.find_all {|c| !c.respond_to?(:text) || !c.text.strip.empty?}
        end
      end

      module InstanceMethods

        public

          # Turn a record into its XML representation.
          def to_xml(b = Builder::XmlMarkup.new(:indent => 2))
            optional_root_tag(parent.class.optional_xml_root_name, b) do |c|
              c.tag!(model.class.xml_node_name || model.model_name) {
                attributes.each do | key, value |
                  field = self.class.fields[key]
                  value = self.send(key) if field[:calculated]
                  xml_value_from_field(b, field, value) unless value.nil?
                end
              }
            end
          end

        protected

          # Add top-level root name if required.
          # E.g. Payments need specifying in the form:
          #   <Payments>
          #     <Payment>
          #       ...
          #     </Payment>
          #   </Payments>
          def optional_root_tag(root_name, b, &block)
            if root_name
              b.tag!(root_name) { |c| yield(c) }
            else
              yield(b)
            end
          end

          # Format an attribute for use in the XML passed to Xero.
          def xml_value_from_field(b, field, value)
            case field[:type]
              when :guid        then b.tag!(field[:api_name], value)
              when :string      then b.tag!(field[:api_name], value)
              when :boolean     then b.tag!(field[:api_name], value ? 'true' : 'false')
              when :integer     then b.tag!(field[:api_name], value.to_i)
              when :decimal
                real_value = case value
                  when BigDecimal   then value.to_s
                  when String       then BigDecimal(value).to_s
                  else              value
                end
                b.tag!(field[:api_name], real_value)

              when :date
                real_value = case value
                  when Date         then value.strftime("%Y-%m-%d")
                  when Time         then value.utc.strftime("%Y-%m-%d")
                  when NilClass     then nil
                  else raise ArgumentError.new("Expected Date or Time object for the #{field[:api_name]} field")
                end
                b.tag!(field[:api_name], real_value)

              when :datetime    then b.tag!(field[:api_name], value.utc.strftime("%Y-%m-%dT%H:%M:%S"))
              when :belongs_to
                value_is_present = (value.respond_to?(:blank?) && !value.blank?) || (!value.nil? && (!value.respond_to?(:length) || (value.respond_to?(:length) && value.length != 0)))
                # you may need to set a belongs_to to nil, at which point it defaults back to an array
                # but in that case we don't want to include it in the XML response
                if value_is_present
                  value.to_xml(b)
                  nil
                else
                  nil
                end

              when :has_many
                if value.size > 0
                  sub_parent = value.first.parent
                  b.tag!(sub_parent.class.xml_root_name || sub_parent.model_name.pluralize) {
                    value.each { | record | record.to_xml(b) }
                  }
                  nil
                end

              when :has_array
                if value.size > 0
                  b.tag!(field[:api_name]) do
                    value.each do |v|
                      b.tag!(field[:api_child_name], v.value)
                    end
                  end
                  nil
                end

            end
          end

          def association_to_xml(association_name)
            builder = Builder::XmlMarkup.new(indent: 2)
            records = send(association_name)

            optional_root_tag(association_name.to_s.camelize, builder) do |b|
              records.each { |record| record.to_xml(b) }
            end
          end
      end

    end
  end
end
