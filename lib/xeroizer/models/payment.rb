module Xeroizer
  module Record
    
    class PaymentModel < BaseModel
        
      set_xml_root_name 'Payments'
      set_permissions :read, :write
      
    end
    
    class Payment < Base
      
      set_primary_key :payment_id
      
      guid      :payment_id
      date      :date
      decimal   :amount
      decimal   :currency_rate
      string    :reference
            
      belongs_to  :account
      belongs_to  :invoice
      
    end
    
  end
end