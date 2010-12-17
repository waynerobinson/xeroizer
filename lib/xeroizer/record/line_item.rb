module Xeroizer
  module Record
    
    class LineItemModel < BaseModel
        
    end
    
    class LineItem < Base
      
      LINE_AMOUNT_TYPES = {
        "Inclusive" =>        'CreditNote lines are inclusive tax',
        "Exclusive" =>        'CreditNote lines are exclusive of tax (default)',
        "NoTax"     =>        'CreditNotes lines have no tax'
      } unless defined?(LINE_AMOUNT_TYPES)
      
      TAX_TYPE = Account::TAX_TYPE unless defined?(TAX_TYPE)
      
      string  :description
      decimal :quantity
      decimal :unit_amount
      string  :account_code
      string  :tax_type
      decimal :tax_amount
      decimal :line_amount
      
      has_many  :tracking, :model_name => 'TrackingCategoryChild'
       
    end
    
  end
end