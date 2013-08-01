module Xeroizer
  module Record
    class AllocationModel < BaseModel
    end

    class Allocation < Base
      decimal :applied_amount
      belongs_to :invoice

      validates_presence_of :invoice
    end
  end
end
