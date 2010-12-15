module Xeroizer
  module Record
    
    class BrandingThemeClass < BaseClass
    
    end
    
    class BrandingTheme < Base
      
      string    :branding_theme_id
      string    :name
      integer   :sort_order
      datetime  :created_date_utc
      
    end
    
  end
end