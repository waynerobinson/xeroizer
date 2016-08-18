module Xeroizer
  module Record
    module RecordAssociationHelper

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        def belongs_to(field_name, options = {})
          internal_field_name = options[:internal_name] || field_name
          internal_singular_field_name = internal_field_name.to_s.singularize

          define_association_attribute(field_name, internal_singular_field_name, :belongs_to, options)

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
        
        alias_method :has_one, :belongs_to

        def has_many(field_name, options = {})
          internal_field_name = options[:internal_name] || field_name
          internal_singular_field_name = internal_field_name.to_s.singularize

          define_association_attribute(field_name, internal_field_name, :has_many, options)

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

            # Ensure that complete record is downloaded before adding new records
            self.send(internal_field_name)

            # Add each record.
            last_record = nil
            records.each do | record |
              record = record_class.build(record, model_parent) if record.is_a?(Hash)
              raise StandardError.new("Record #{record.class.name} is not a #{record_class.name}.") unless record.is_a?(record_class)
              self.attributes[field_name] ||= []
              self.attributes[field_name] << record
              last_record = record
            end

            last_record # last record
          end

        end

        def define_association_attribute(field_name, internal_field_name, association_type, options)
          define_simple_attribute(field_name, association_type, options.merge!(:skip_writer => true), ((association_type == :has_many) ? [] : nil))

          internal_field_name = options[:internal_name] || field_name
          internal_singular_field_name = internal_field_name.to_s.singularize
          model_name = options[:model_name] ? options[:model_name].to_sym : field_name.to_s.singularize.camelize.to_sym

          define_method "#{internal_field_name}=".to_sym do | value |
            record_class = Xeroizer::Record.const_get(model_name)
            case value
              when Hash
                self.attributes[field_name] = ((association_type == :has_many) ? [] : nil)
                case association_type
                  when :has_many
                    self.attributes[field_name] = []
                    self.send("add_#{internal_singular_field_name}".to_sym, value)

                  when :belongs_to
                    self.attributes[field_name] = Xeroizer::Record.const_get(model_name).build(value, new_model_class(model_name))

                end

              when Array
                self.attributes[field_name] = ((association_type == :has_many) ? [] : nil)
                value.each do | single_value |
                  case single_value
                    when Hash         then send("add_#{internal_singular_field_name}".to_sym, single_value)
                    when record_class then self.attributes[field_name] << single_value
                    else                   raise AssociationTypeMismatch.new(record_class, single_value.class)
                  end
                end

              when record_class
                self.attributes[field_name] = ((association_type == :has_many) ? [value] : value)

              when NilClass
                self.attributes[field_name] = []

              else
                raise AssociationTypeMismatch.new(record_class, value.class)
            end
          end

          # Override reader for this association if this association belongs
          # to a summary-typed record. This will automatically attempt to download
          # the complete version of the record before accessing the association.
          if list_contains_summary_only?
            define_method internal_field_name do
              download_complete_record! unless new_record? || options[:list_complete] || options[:complete_on_page] && paged_record_downloaded? || complete_record_downloaded?
              self.attributes[field_name] || ((association_type == :has_many) ? [] : nil)
            end
          end
        end

      end

    end
  end
end
