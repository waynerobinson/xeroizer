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
      
      has_many  :tracking, :model_name => 'TrackingCategoryChild'
      
      # Swallow assignment of attributes that should only be calculated automatically.
      def line_amount=(value);  raise SettingTotalDirectlyNotSupported.new(:line_amount);   end
      
      # Calculate the line_total (if there is a quantity and unit_amount).
      # Description-only lines have been allowed since Xero V2.09.
      def line_amount
        BigDecimal((quantity * unit_amount).to_s).round(2) if quantity && unit_amount
      end
      
    end
    
  end
end
