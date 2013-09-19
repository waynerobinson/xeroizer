module Xeroizer
  module Record
    
    class OrganisationModel < BaseModel
    
      set_api_controller_name 'Organisation'
      set_permissions :read
      
    end
    
    class Organisation < Base
      
      string    :api_key, :api_name => 'APIKey'
      string    :name
      string    :legal_name
      string    :short_code
      boolean   :pays_tax
      string    :version
      string    :organisation_type
      string    :base_currency
      string    :country_code
      boolean   :is_demo_company
      string    :organisation_status
      integer   :financial_year_end_day
      integer   :financial_year_end_month
      date      :period_lock_date
      date      :end_of_year_lock_date
      string    :tax_number
      string    :registration_number
      datetime  :created_date_utc, :api_name => 'CreatedDateUTC'

    end
    
  end
end