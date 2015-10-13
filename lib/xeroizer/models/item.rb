module Xeroizer
  module Record
    
    class ItemModel < BaseModel
        
      set_permissions :read, :write, :update
      
    end
    
    class Item < Base
      
      set_primary_key :item_id
      set_possible_primary_keys :item_id, :code
      
      guid    :item_id
      string  :code
      string  :description
      string  :purchase_description
      string  :name

      decimal :unit_price
      decimal :total_cost_pool
      decimal :quantity_on_hand

      boolean :is_sold
      boolean :is_purchased
      boolean :is_tracked_as_inventory
      string  :inventory_asset_account_code

      belongs_to :purchase_details, :model_name => 'ItemPurchaseDetails'
      belongs_to :sales_details, :model_name => 'ItemSalesDetails'
      
      validates_presence_of :code
      
    end
    
  end
end
