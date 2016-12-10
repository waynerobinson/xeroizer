require "xeroizer/models/attachment"

module Xeroizer
  module Record
    
    class PurchaseOrderModel < BaseModel
        
      set_permissions :read, :write, :update

      include AttachmentModel::Extensions
    end
    
    class PurchaseOrder < Base
      include Attachment::Extensions
      
      set_primary_key :purchase_order_id
      set_possible_primary_keys :purchase_order_id
      
      guid    :purchase_order_id
      string  :purchase_order_number
      string  :date_string
      date    :date
      string  :delivery_date_string
      date    :delivery_date
      string  :delivery_address
      string  :attention_to
      string  :telephone
      string  :delivery_instructions
      boolean :has_errors 
      boolean :is_discounted 
      string  :reference
      string  :type
      string  :currency_rate
      string  :currency_code
      guid  :branding_theme_id 
      string  :status 
      string  :line_amount_types
      string  :sub_total
      string  :total_tax
      string  :total 
      date    :updated_date_UTC
      boolean :has_attachments

      has_many     :line_items
      belongs_to :contact, :model_name => 'Contact'      
    end
    
  end
end
