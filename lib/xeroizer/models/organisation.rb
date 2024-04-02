require "xeroizer/models/payment_terms"
module Xeroizer
  module Record
    
    class OrganisationModel < BaseModel
    
      set_api_controller_name 'Organisation'
      set_permissions :read
      
    end
    
    class Organisation < Base
      
      SALES_TAX_BASIS = {
        'NZ' => 
          {'PAYMENTS' => 'Payments Basis',
           'INVOICE' => 'Invoice Basis',
           'NONE' => 'None'},
        'GB' => 
          {
            'CASH' => 'Cash Scheme',
            'ACCRUAL' => 'Accrual Scheme',
            'FLATRATECASH' => 'Flate Rate Cash Scheme',
            'NONE' => 'None'
          },
        'GLOBAL' =>
          {
            'CASH' => 'Cash Basis',
            'ACCRUALS' => 'Accruals Basis',
            'NONE' => 'None'
          }
      } unless defined?(SALES_TAX_BASES)

      SALES_TAX_BASES = SALES_TAX_BASIS.values.map(&:keys).flatten.sort
      
      string    :api_key, :api_name => 'APIKey'
      string    :name
      string    :legal_name
      string    :short_code
      string    :organisation_id
      boolean   :pays_tax
      string    :version
      string    :organisation_type
      string    :organisation_entity_type
      string    :line_of_business
      string    :base_currency
      string    :country_code
      boolean   :is_demo_company
      string    :organisation_status
      integer   :financial_year_end_day
      integer   :financial_year_end_month
      string    :sales_tax_basis
      string    :sales_tax_period
      date      :period_lock_date
      date      :end_of_year_lock_date
      string    :tax_number
      string    :registration_number
      string    :timezone
      datetime_utc  :created_date_utc, :api_name => 'CreatedDateUTC'
      string    :sales_tax_basis
      string    :sales_tax_period
      string    :edition

      has_many :addresses
      has_many :phones
      has_many :external_links
      has_one :payment_terms, :model_name => 'PaymentTerms'

      validates :sales_tax_basis, :message => "is not a valid option" do
        valid = true
        if sales_tax_basis

          valid_bases = (SALES_TAX_BASIS[country_code] || SALES_TAX_BASIS['GLOBAL']).keys

          unless valid_bases.include?(sales_tax_basis)
            valid = false
          end
        end
        
        valid
      end

    end
    
  end
end
