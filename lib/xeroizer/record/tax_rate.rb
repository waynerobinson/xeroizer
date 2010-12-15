module Xeroizer
  module Record
    
    class TaxRateClass < BaseClass
            
    end
    
    class TaxRate < Base
      
      string  :name
      string  :tax_type
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