module Xeroizer
  module Record
    module Payroll

      class PayTemplateModel < PayrollBaseModel

        set_permissions :read, :write, :update

        set_standalone_model true
          
        set_xml_root_name 'PayTemplate'
        set_xml_node_name 'PayTemplate'

        def api_url(options = {})
          "employees/#{options.delete(:employee_id)}/paytemplates"
        end
      end

      class PayTemplate < PayrollBase

        set_primary_key false

        has_many      :earnings_lines
        has_many      :deduction_lines
        has_many      :super_lines
        has_many      :reimbursement_lines
        has_many      :leave_lines

        # US Payroll fields
        has_many      :benefit_lines
        # UK: https://developer.xero.com/documentation/payroll-api-uk/employeepaytemplates
        has_many      :earning_templates
        guid          :employee_id

      end

    end
  end
end
