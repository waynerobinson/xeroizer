module Xeroizer
  module Record
    module Payroll

      class PayItemsModel < PayrollBaseModel

        set_permissions :read

        def parse_response(response_xml, options = {})
          Response.parse(response_xml, options) do | response, elements, response_model_name |
            puts "elements: #{elements.inspect}"
            puts "model_name: #{model_name}"
            puts "response_model_name: #{response_model_name}"
            if model_name == response_model_name
              @response = response
              parse_records(response, [self], paged_records_requested?(options), (options[:base_module] || Xeroizer::Record::Payroll))
            end
          end
        end

      end

      class PayItems < PayrollBase

        has_many      :earnings_types
        has_many      :benefit_types
        has_many      :deduction_types
        has_many      :reimbursement_types
        has_many      :time_off_types

      end
    end
  end
end
