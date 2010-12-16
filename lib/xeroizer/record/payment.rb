module Xeroizer
  module Record
    
    class PaymentClass < BaseClass
        
      set_permissions :write
      
    end
    
    class Payment < Base
            
      string    :payment_id
      date      :date
      decimal   :amount
      
      string    :invoice_id
      string    :invoice_number
      string    :account_id
      string    :code
      
      belongs_to  :account
      belongs_to  :invoice
      
    end
    
  end
end