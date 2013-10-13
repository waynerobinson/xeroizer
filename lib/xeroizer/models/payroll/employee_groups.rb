module Xeroizer
  module Record
    module Payroll
    
      class EmployeeGroupsModel < PayrollBaseModel
          
        set_standalone_model true
        set_xml_root_name 'EmployeeGroups'
        set_xml_node_name 'EmployeeGroups'
      end
    
      # child of TrackingCategories
      class EmployeeGroups < PayrollBase

        set_primary_key false
        
        guid        :tracking_category_id
        string      :tracking_category_name

      end

    end 
  end
end
