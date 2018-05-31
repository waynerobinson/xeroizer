require 'xeroizer/application_http_proxy'

module Xeroizer
  module Record
    module BaseModelHttpProxy

      def self.included(base)
        base.send :include, Xeroizer::ApplicationHttpProxy
        base.send :include, InstanceMethods
      end

      module InstanceMethods

        protected

          # Parse parameters for GET requests.
          def parse_params(options)
            params = {}
            params[:ModifiedAfter]  = options[:modified_since] if options[:modified_since]
            params[:includeArchived]  = options[:include_archived] if options[:include_archived]
            params[:order]        = options[:order] if options[:order]
            params[:createdByMyApp] = options[:createdByMyApp] if options[:createdByMyApp]

            params[:IDs]            = filterize(options[:IDs]) if options[:IDs]
            params[:InvoiceNumbers] = filterize(options[:InvoiceNumbers]) if options[:InvoiceNumbers]
            params[:ContactIDs]     = filterize(options[:ContactIDs]) if options[:ContactIDs]
            params[:Statuses]       = filterize(options[:Statuses]) if options[:Statuses]

            if options[:where]
              params[:where] =  case options[:where]
                                  when String   then options[:where]
                                  when Hash     then parse_where_hash(options[:where])
                                end
            end
            params[:offset] = options[:offset] if options[:offset]
            params[:page] = options[:page] if options[:page]
            params
          end

          # Parse the :where part of the options for GET parameters and construct a valid
          # .Net version of the criteria to pass to Xero.
          #
          # Attribute names can be modified as follows to change the expression used:
          #   {attribute_name}_is_greater_than or {attribute_name}> uses '>'
          #   {attribute_name}_is_greater_than_or_equal_to or {attribute_name}>= uses '>='
          #   {attribute_name}_is_less_than or {attribute_name}< uses '<'
          #   {attribute_name}_is_less_than_or_equal_to or {attribute_name}< uses '<='
          #   DEFAULT: '=='
          def parse_where_hash(where)
            conditions = []
            where.each do | key, value |
              (attribute_name, expression) = extract_expression_from_attribute_name(key)
              (_, field) = model_class.fields.find { | k, v | v[:internal_name] == attribute_name }
              if field
                conditions << where_condition_part(field, expression, value)
              else
                raise InvalidAttributeInWhere.new(model_name, attribute_name)
              end
            end
            conditions.map { | (attr, expression, value) | "#{attr}#{expression}#{value}"}.join('&&')
          end

          # Extract the attribute name and expression from the attribute.
          #
          # @return [Array] containing [actual_attribute_name, expression]
          def extract_expression_from_attribute_name(key)
            case key.to_s
              when /(_is_not|\<\>)$/
                [
                  key.to_s.gsub(/(_is_not|\<\>)$/, '').to_sym,
                  '<>'
                ]

              when /(_is_greater_than|\>)$/
                [
                  key.to_s.gsub(/(_is_greater_than|\>)$/, '').to_sym,
                  '>'
                ]

              when /(_is_greater_than_or_equal_to|\>\=)$/
                [
                  key.to_s.gsub(/(_is_greater_than_or_equal_to|\>\=)$/, '').to_sym,
                  '>='
                ]

              when /(_is_less_than|\<)$/
                [
                  key.to_s.gsub(/(_is_less_than|\<)$/, '').to_sym,
                  '<'
                ]

              when /(_is_less_than_or_equal_to|\<\=)$/
                [
                  key.to_s.gsub(/(_is_less_than_or_equal_to|\<\=)$/, '').to_sym,
                  '<='
                ]

              else
                [key, '==']

            end
          end

          # Creates a condition part array containing the:
          #   * Field's API name
          #   * Expression
          #   * .Net formatted value.
          def where_condition_part(field, expression, value)
            case field[:type]
              when :guid        then ["#{field[:api_name]}.ToString()", expression, "\"#{value}\""]
              when :string      then [field[:api_name], expression, "\"#{value}\""]
              when :boolean     then [field[:api_name], expression, value ? 'true' : 'false']
              when :integer     then [field[:api_name], expression, value.to_s]
              when :decimal     then [field[:api_name], expression, value.to_s]
              when :date        then [field[:api_name], expression, "DateTime.Parse(\"#{value.strftime("%Y-%m-%d")}\")"]
              when :datetime    then [field[:api_name], expression, "DateTime.Parse(\"#{value.utc.strftime("%Y-%m-%dT%H:%M:%S")}\")"]
              when :datetime_utc then [field[:api_name], expression, "DateTime.Parse(\"#{value.utc.strftime("%Y-%m-%dT%H:%M:%S")}\")"]
              when :belongs_to  then
              when :has_many    then
            end
          end

        private

          # Filtering params expect a comma separated list of strings 
          def filterize(values)
            case values
              when String then values
              when Array  then values.join(',')
            end
          end

      end

    end
  end
end
