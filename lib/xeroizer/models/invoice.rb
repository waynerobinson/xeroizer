module Xeroizer
  module Record
    
    class InvoiceModel < BaseModel
        
      set_permissions :read, :write, :update
      
    end
    
    class Invoice < Base
      
      INVOICE_TYPE = {
        'ACCREC' =>           'Accounts Receivable',
        'ACCPAY' =>           'Accounts Payable'
      } unless defined?(INVOICE_TYPE)

      INVOICE_STATUS = {
        'AUTHORISED' =>       'Approved invoices awaiting payment',
        'DELETED' =>          'Draft invoices that are deleted',
        'DRAFT' =>            'Invoices saved as draft or entered via API',
        'PAID' =>             'Invoices approved and fully paid',
        'SUBMITTED' =>        'Invoices entered by an employee awaiting approval',
        'VOID' =>             'Approved invoices that are voided'
      } unless defined?(INVOICE_STATUS)
      
      set_primary_key :invoice_id
      set_possible_primary_keys :invoice_id, :invoice_number
      list_contains_summary_only true
      
      string    :invoice_id, :api_name => 'InvoiceID'
      string    :invoice_number
      string    :reference
      string    :branding_theme_id
      string    :url
      string    :type
      date      :date
      date      :due_date
      string    :status
      string    :line_amount_types
      decimal   :sub_total, :calculated => true
      decimal   :total_tax, :calculated => true
      decimal   :total, :calculated => true
      decimal   :amount_due
      decimal   :amount_paid
      decimal   :amount_credited
      datetime  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      string    :currency_code
      datetime  :fully_paid_on_date
      
      belongs_to  :contact
      has_many    :line_items
      has_many    :payments
      
      public
      
        # Helper method to check if the invoice is accounts payable.
        def accounts_payable?
          type == 'ACCPAY'
        end

        # Helper method to check if the invoice is accounts receivable.
        def accounts_receivable?
          type == 'ACCREC'
        end
        
        # Swallow assignment of attributes that should only be calculated automatically.
        def sub_total=(value);  raise SettingTotalDirectlyNotSupported.new(:sub_total);   end
        def total_tax=(value);  raise SettingTotalDirectlyNotSupported.new(:total_tax);   end
        def total=(value);      raise SettingTotalDirectlyNotSupported.new(:total);       end

        # Calculate sub_total from line_items.
        def sub_total
          if new_record? || (!new_record? && line_items && line_items.size > 0)
            (line_items || []).inject(BigDecimal.new('0')) { | sum, line_item | sum + line_item.line_amount }
          else
            attributes[:sub_total]
          end
        end

        # Calculate total_tax from line_items.
        def total_tax
          if new_record? || (!new_record? && line_items && line_items.size > 0)
            (line_items || []).inject(BigDecimal.new('0')) { | sum, line_item | sum + line_item.tax_amount }
          else
            attributes[:total_tax]
          end
        end

        # Calculate the total from line_items.
        def total
          sub_total + total_tax
        end
      
    end
    
  end
end