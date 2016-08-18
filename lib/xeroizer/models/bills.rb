module Xeroizer
  module Record
    
    class BillsModel < BaseModel
      set_permissions :read
    end
    
    class Bills < Base
      string :day
      string :type
    end
  end
end
