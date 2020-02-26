module Xeroizer
  class PayrollApplication

    attr_reader :application

    # Factory for new Payroll BaseModel instances with the class name `record_type`.
    # Only creates the instance if one doesn't already exist.
    #
    # @param [Symbol] record_type Symbol of the record type (e.g. :Invoice)
    # @return [BaseModel] instance of BaseModel subclass matching `record_type`
    def self.record(record_type)
      define_method record_type do
        var_name = "@#{record_type}_cache".to_sym
        unless instance_variable_defined?(var_name)
          instance_variable_set(var_name, Xeroizer::Record::Payroll.const_get("#{record_type}Model".to_sym).new(self.application, record_type.to_s))
        end
        instance_variable_get(var_name)
      end
    end

    record :Employee
    record :PayRun
    record :Paystub
    record :PayItems
    record :PaySchedule
    record :LeaveApplication

    def initialize(application)
      @application = application
    end

  end
end
