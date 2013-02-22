module Xeroizer
  module Record
    
    class TaxRateModel < BaseModel
            
      set_permissions :read
      
    end
    
    class TaxRate < Base
      
      string  :name
      string  :tax_type
      string  :status
      boolean :can_apply_to_assets
      boolean :can_apply_to_equity
      boolean :can_apply_to_expenses
      boolean :can_apply_to_liabilities
      boolean :can_apply_to_revenue
      decimal :display_tax_rate
      decimal :effective_rate
      
    end
    
  end
end