module Xeroizer
  module Record
    
    class PayrollBase < Xeroizer::Record::Base
      
      class_inheritable_attributes :fields, :possible_primary_keys, :primary_key_name, :summary_only, :validators

      def self.belongs_to(field_name, options = {})
        super(field_name, {:base_module => Xeroizer::Record::Payroll}.merge(options))
      end

      def self.has_array(field_name, options = {})
        super(field_name, {:base_module => Xeroizer::Record::Payroll}.merge(options))
      end

      def self.has_many(field_name, options = {})
        super(field_name, {:base_module => Xeroizer::Record::Payroll}.merge(options))
      end

      def self.has_one(field_name, options = {})
        super(field_name, {:base_module => Xeroizer::Record::Payroll}.merge(options))
      end
      
      public

        def initialize(parent)
          super(parent)
          self.api_method_for_creating = :http_post
          self.api_method_for_updating = :http_post
        end

        def new_model_class(model_name)
          Xeroizer::Record::Payroll.const_get("#{model_name}Model".to_sym).new(parent.application, model_name.to_s)
        end

    end

  end
end
