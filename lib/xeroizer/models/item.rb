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
      
      belongs_to :purchase_details, :model_name => 'ItemPurchaseDetails'
      belongs_to :sales_details, :model_name => 'ItemSalesDetails'
      
      validates_presence_of :code
      
    end
    
  end
end
