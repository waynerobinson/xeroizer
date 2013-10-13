module Xeroizer
  module Record
    module Payroll
    
      class TrackingCategoriesModel < PayrollBaseModel

        set_permissions :read
          
        set_standalone_model true
        set_xml_root_name 'TrackingCategories'
        set_xml_node_name 'TrackingCategories'
      end
    
      # child of Settings
      class TrackingCategories < PayrollBase

        set_primary_key false
        
        has_many      :employee_groups
        has_many      :timesheet_categories

      end

    end 
  end
end
