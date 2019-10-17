module Xeroizer
  module Record
    module Payroll
    
      class SettingModel < PayrollBaseModel
          
        set_permissions :read

        set_standalone_model true
        set_xml_root_name 'Settings'
        set_xml_node_name 'Settings'
      end
      
      class Setting < PayrollBase

        set_primary_key false
        
        has_many      :accounts
        has_many      :timesheet_categories, :model_name => 'TimesheetCategories'
        has_many      :employee_groups, :model_name => 'EmployeeGroups'
        integer       :days_in_payroll_year

      end

    end 
  end
end
