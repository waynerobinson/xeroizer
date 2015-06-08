module Xeroizer
  module Record
    
    class BrandingThemeModel < BaseModel
    
      set_permissions :read
    
    end
    
    class BrandingTheme < Base
      
      set_primary_key :branding_theme_id
      
      guid      :branding_theme_id
      string    :name
      integer   :sort_order
      datetime_utc  :created_date_utc, :api_name => 'CreatedDateUTC'

    end
    
  end
end