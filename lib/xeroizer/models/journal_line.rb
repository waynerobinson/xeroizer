module Xeroizer
  module Record
    
    class JournalLineModel < BaseModel
        
    end
    
    class JournalLine < Base
      
      set_primary_key :journal_line_id
      
      guid     :journal_line_id
      guid     :account_id
      string   :account_code
      string   :account_type
      string   :account_name
      decimal  :net_amount
      decimal  :gross_amount
      decimal  :tax_amount
      string   :tax_type
      string   :tax_name
      string   :description

      has_many :tracking_categories, :model_name => 'JournalLineTrackingCategory'
       
    end
    
  end
end