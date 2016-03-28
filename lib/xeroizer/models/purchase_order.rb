module Xeroizer
  module Record
    
    class PurchaseOrderModel < BaseModel
        
      set_permissions :read, :write, :update
      
    end
    
    class PurchaseOrder < Base
      
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
      string  :branding_theme_id 
      string  :status 
      string  :line_amount_types
      string  :sub_total
      string  :total_tax
      string  :total 
      date    :updated_date_UTC
      boolean :has_attachments

      # decimal :unit_price
      # decimal :total_cost_pool # read only
      # decimal :quantity_on_hand # read only

      # boolean :is_sold # can be set to false, only if description, and sales_details are nil
      # boolean :is_purchased # can be set to false, only if purchase_description, and purchase_details are nil
      # boolean :is_tracked_as_inventory # read only, infered from inventory_asset_account_code, cogs_account_code, is_sold and is_purchased
      # string  :inventory_asset_account_code
      has_many     :line_items
      belongs_to :contact, :model_name => 'Contact'
      # belongs_to :sales_details, :model_name => 'ItemSalesDetails'
      
      # validates_presence_of :code
      
    end
    
  end
end
