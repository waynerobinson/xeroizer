require "xeroizer/models/bills"
require "xeroizer/models/sales"

module Xeroizer
  module Record
    
    class PaymentTermsModel < BaseModel
      set_permissions :read
    end
    
    class PaymentTerms < Base
      has_one :bills, :model_name => 'Bills'
      has_one :sales, :model_name => 'Sales'
    end
  end
end
