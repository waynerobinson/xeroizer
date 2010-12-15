module Xeroizer
  module Record
    
    class JournalLineClass < BaseClass
        
    end
    
    class JournalLine < Base
      
       string   :journal_line_id
       string   :account_id
       string   :account_code
       string   :account_type
       string   :account_name
       decimal  :net_amount
       decimal  :gross_amount
       decimal  :tax_amount
       string   :tax_type
       string   :tax_name
       
       has_many :tracking_categories, :model_name => 'TrackingCategoryChild'
       
    end
    
  end
end