module Xeroizer
  module Record
    
    class SalesModel < BaseModel
      set_permissions :read
    end
    
    class Sales < Base
      string :day
      string :type
    end
  end
end
