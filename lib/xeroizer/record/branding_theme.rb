module Xeroizer
  module Record
    
    class BrandingThemeClass < BaseClass
    
      set_permissions :read
    
    end
    
    class BrandingTheme < Base
      
      string    :branding_theme_id
      string    :name
      integer   :sort_order
      datetime  :created_date_utc, :api_name => 'CreatedDateUTC'

    end
    
  end
end