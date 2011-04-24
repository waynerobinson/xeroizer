module Xeroizer
  module Record
    
    class ContactGroupModel < BaseModel      
    end
    
    class ContactGroup < Base
      
      guid :contact_group_id
      string :name
      string :status
      
    end
    
  end
end