module Xeroizer
  module Record
    
    class ManualJournalLineModel < BaseModel
                    
      set_xml_root_name 'JournalLines'
      set_xml_node_name 'JournalLine'
                    
    end
    
    class ManualJournalLine < Base

      string    :description
      string    :tax_type
      string    :account_code
      decimal   :line_amount
      decimal   :tax_amount
      
      has_many  :tracking, :model_name => 'TrackingCategoryChild'

      validates_presence_of :account_code, :line_amount      
            
      public
      
    end
    
  end
end