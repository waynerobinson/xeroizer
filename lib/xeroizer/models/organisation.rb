module Xeroizer
  module Record
    
    class OrganisationModel < BaseModel
    
      set_api_controller_name 'Organisation'
      set_permissions :read
      
    end
    
    class Organisation < Base
      
      string    :name
      string    :legal_name
      boolean   :pays_tax
      string    :version
      string    :organisation_type
      string    :base_currency
      integer   :financial_year_end_day
      integer   :financial_year_end_month
      date      :period_lock_date
      date      :end_of_year_lock_date
      string    :registration_number
      datetime  :created_date_utc, :api_name => 'CreatedDateUTC'

    end
    
  end
end