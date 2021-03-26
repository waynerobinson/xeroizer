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

      decimal :total_cost_pool # read only
      decimal :quantity_on_hand # read only

      boolean :is_sold # can be set to false, only if description, and sales_details are nil
      boolean :is_purchased # can be set to false, only if purchase_description, and purchase_details are nil
      boolean :is_tracked_as_inventory # read only, infered from inventory_asset_account_code, cogs_account_code, is_sold and is_purchased
      string  :inventory_asset_account_code

      datetime_utc :updated_date_utc, api_name: 'UpdatedDateUTC'
      
      belongs_to :purchase_details, :model_name => 'ItemPurchaseDetails'
      belongs_to :sales_details, :model_name => 'ItemSalesDetails'
      
      validates_presence_of :code
      
    end
    
  end
end
