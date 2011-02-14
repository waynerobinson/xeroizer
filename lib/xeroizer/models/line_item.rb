require 'xeroizer/models/account'

module Xeroizer
  module Record
    
    class LineItemModel < BaseModel
        
    end
    
    class LineItem < Base
      
      LINE_AMOUNT_TYPE = {
        "Inclusive" =>        'CreditNote lines are inclusive tax',
        "Exclusive" =>        'CreditNote lines are exclusive of tax (default)',
        "NoTax"     =>        'CreditNotes lines have no tax'
      } unless defined?(LINE_AMOUNT_TYPE)
      LINE_AMOUNT_TYPES = LINE_AMOUNT_TYPE.keys.sort
      
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
      
      # Calculate the line_total.
      def line_amount
        quantity * unit_amount
      end
      
    end
    
  end
end