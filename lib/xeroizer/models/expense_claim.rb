module Xeroizer
  module Record
    
    class ExpenseClaimModel < BaseModel
        
      set_permissions :read, :write, :update
      
    end
    
    class ExpenseClaim < Base
      
      set_primary_key :expense_claim_id

      guid          :expense_claim_id
      string        :status
      decimal       :total
      decimal       :amount_due
      decimal       :amount_paid
      date          :payment_due_date
      date          :reporting_date
      datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      
      belongs_to    :user
      has_many      :receipts
      
    end
    
  end
end