module Xeroizer
  module Record
    module Payroll

      class TrackingCategoriesModel < PayrollBaseModel

        set_permissions :read

        set_standalone_model true
        set_xml_root_name 'TrackingCategories'
        set_xml_node_name 'TrackingCategories'

        def api_url(options = {})
          if options.has_key?(:use_json_api) && options[:use_json_api]
            "settings/trackingCategories"
          end
        end
      end

      # child of Settings
      class TrackingCategories < PayrollBase

        set_primary_key false

        guid          :employee_groups_tracking_category_id
        guid          :timesheet_tracking_category_id

        has_many      :employee_groups
        has_many      :timesheet_categories

      end

    end
  end
end
