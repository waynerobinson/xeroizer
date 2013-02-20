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
      
      set_primary_key :contact_id
      set_possible_primary_keys :contact_id, :contact_number
      list_contains_summary_only true
      
      guid          :contact_id
      string        :contact_number
      string        :contact_status
      string        :name
      string        :tax_number
      string        :bank_account_details
      string        :accounts_receivable_tax_type
      string        :accounts_payable_tax_type
      string        :first_name
      string        :last_name
      string        :email_address
      string        :skype_user_name
      string        :contact_groups
      string        :default_currency
      datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      boolean       :is_supplier
      boolean       :is_customer
      
      has_many  :addresses, :list_complete => true
      has_many  :phones, :list_complete => true
      has_many  :contact_groups
      
      validates_presence_of :name
      validates_inclusion_of :contact_status, :in => CONTACT_STATUS.keys, :allow_blanks => true
      
    end
    
  end
end
