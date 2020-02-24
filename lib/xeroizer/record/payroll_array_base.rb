module Xeroizer
  module Record
    
    class PayrollArrayBase < PayrollBase

      class_inheritable_attributes :fields, :possible_primary_keys, :primary_key_name, :summary_only, :validators

      def self.build(value, parent)
        record = new(parent)
        record.value = value
        record
      end

    end

  end
end
