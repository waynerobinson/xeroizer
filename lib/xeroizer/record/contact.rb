module Xeroizer
  module Record
    
    class ContactClass < BaseClass
            
    end
    
    class Contact < Base
      
      string    :contact_id
      string    :contact_status
      string    :name
      string    :tax_number
      string    :bank_account_details
      string    :accounts_receivable_tax_type
      string    :accounts_payable_tax_type
      string    :first_name
      string    :last_name
      string    :email_address
      string    :contact_groups
      string    :default_currency
      datetime  :updated_date_utc
      boolean   :is_supplier
      boolean   :is_customer
      has_many  :addresses
      has_many  :phones
      
    end
    
  end
end