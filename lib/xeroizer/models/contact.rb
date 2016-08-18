require "xeroizer/models/contact_person"
require "xeroizer/models/balances"
require "xeroizer/models/batch_payments"
require "xeroizer/models/payment_terms"

module Xeroizer
  module Record

    class ContactModel < BaseModel

      set_permissions :read, :write, :update

    end

    class Contact < Base

      CONTACT_STATUS = {
        'ACTIVE' =>     'Active',
        'DELETED' =>    'Deleted',
        'ARCHIVED' => 'Archived'
      } unless defined?(CONTACT_STATUS)

      set_primary_key :contact_id
      set_possible_primary_keys :contact_id, :contact_number
      list_contains_summary_only true

      guid          :contact_id
      string        :contact_number
      string        :contact_status
      string        :account_number
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
      string        :purchases_default_account_code
      string        :sales_default_account_code
      datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      boolean       :is_supplier
      boolean       :is_customer

      has_many  :addresses, :list_complete => true
      has_many  :phones, :list_complete => true
      has_many  :contact_groups
      has_many  :contact_persons, :internal_name => :contact_people

      has_many :sales_tracking_categories, :model_name => 'ContactSalesTrackingCategory'
      has_many :purchases_tracking_categories, :model_name => 'ContactPurchasesTrackingCategory'

      has_one :balances ,:model_name => 'Balances', :list_complete => true
      has_one :batch_payments ,:model_name => 'BatchPayments', :list_complete => true
      has_one :payment_terms ,:model_name => 'PaymentTerms', :list_complete => true

      validates_presence_of :name, :unless => Proc.new { | contact | contact.contact_id.present?}
      validates_inclusion_of :contact_status, :in => CONTACT_STATUS.keys, :allow_blanks => true

      def email_address?
        email_address.present?
      end

    end

  end
end
