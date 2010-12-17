module Xeroizer
  module Record
    
    class ContactModel < BaseModel
            
      set_permissions :read, :write, :update
      
    end
    
    class Contact < Base
      
      CONTACT_STATUS = {
        'ACTIVE' =>     'Active',
        'DELETED' =>    'Deleted'
      } unless defined?(CONTACT_STATUS)
      
      set_possible_primary_keys :contact_id, :contact_number
      
      string    :contact_id, :api_name => 'ContactID'
      string    :contact_number
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
      datetime  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      boolean   :is_supplier
      boolean   :is_customer
      
      has_many  :addresses
      has_many  :phones
      
      validates_presence_of :name
      
    end
    
  end
end