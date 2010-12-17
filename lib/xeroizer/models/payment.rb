module Xeroizer
  module Record
    
    class PaymentModel < BaseModel
        
      set_permissions :write
      
    end
    
    class Payment < Base
            
      string    :payment_id, :api_name => 'PaymentID'
      date      :date
      decimal   :amount
      
      string    :invoice_id, :api_name => 'InvoiceID'
      string    :invoice_number
      string    :account_id, :api_name => 'AccountID'
      string    :code
      
      belongs_to  :account
      belongs_to  :invoice
      
    end
    
  end
end