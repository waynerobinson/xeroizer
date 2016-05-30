module Xeroizer
  module Record

    class PaymentTermsModel < BaseModel
    end
    
    class PaymentTerms < Base
      belongs_to :bills, :model_name => 'PaymentTermsBills'
      belongs_to :sales, :model_name => 'PaymentTermsSales'
    end

  end
end