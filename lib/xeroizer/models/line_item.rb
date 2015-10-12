require 'xeroizer/models/account'
require 'xeroizer/models/line_amount_type'

module Xeroizer
  module Record
    class LineItemModel < BaseModel
        
    end
    
    class LineItem < Base
      TAX_TYPE = Account::TAX_TYPE unless defined?(TAX_TYPE)
      
      string  :item_code
      string  :description
      decimal :quantity
      decimal :unit_amount
      string  :account_code
      string  :tax_type
      decimal :tax_amount
      decimal :line_amount, :calculated => true
      decimal :discount_rate
      string  :line_item_id
      
      has_many  :tracking, :model_name => 'TrackingCategoryChild'
      
      def line_amount=(line_amount)
        @line_amount_set = true
        attributes[:line_amount] = line_amount
      end
            
      # Calculate the line_total (if there is a quantity and unit_amount).
      # Description-only lines have been allowed since Xero V2.09.
      def line_amount(summary_only = false)
        return attributes[:line_amount] if summary_only || @line_amount_set
        
        BigDecimal((quantity * unit_amount).to_s).round(2) if quantity && unit_amount
      end
      
    end
    
  end
end
