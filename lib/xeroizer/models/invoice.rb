module Xeroizer
  module Record
    
    class InvoiceModel < BaseModel
        
      set_permissions :read, :write, :update
      
      public
      
        # Retrieve the PDF version of the invoice matching the `id`.
        # @param [String] id invoice's ID.
        # @param [String] filename optional filename to store the PDF in instead of returning the data.
        def pdf(id, filename = nil)
          pdf_data = @application.http_get(@application.client, "#{url}/#{CGI.escape(id)}", :response => :pdf)
          if filename
            File.open(filename, "w") { | fp | fp.write pdf_data }
            nil
          else
            pdf_data
          end
        end
      
    end
    
    class Invoice < Base
      
      INVOICE_TYPE = {
        'ACCREC' =>           'Accounts Receivable',
        'ACCPAY' =>           'Accounts Payable'
      } unless defined?(INVOICE_TYPE)
      INVOICE_TYPES = INVOICE_TYPE.keys.sort

      INVOICE_STATUS = {
        'AUTHORISED' =>       'Approved invoices awaiting payment',
        'DELETED' =>          'Draft invoices that are deleted',
        'DRAFT' =>            'Invoices saved as draft or entered via API',
        'PAID' =>             'Invoices approved and fully paid',
        'SUBMITTED' =>        'Invoices entered by an employee awaiting approval',
        'VOIDED' =>           'Approved invoices that are voided'
      } unless defined?(INVOICE_STATUS)
      INVOICE_STATUSES = INVOICE_STATUS.keys.sort
      
      LINE_AMOUNT_TYPE = {
        "Inclusive" =>        'CreditNote lines are inclusive tax',
        "Exclusive" =>        'CreditNote lines are exclusive of tax (default)',
        "NoTax"     =>        'CreditNotes lines have no tax'
      } unless defined?(LINE_AMOUNT_TYPE)
      LINE_AMOUNT_TYPES = LINE_AMOUNT_TYPE.keys.sort
      
      set_primary_key :invoice_id
      set_possible_primary_keys :invoice_id, :invoice_number
      list_contains_summary_only true
      
      guid      :invoice_id
      string    :invoice_number
      string    :reference
      guid      :branding_theme_id
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
      boolean   :sent_to_contact
      
      belongs_to  :contact
      has_many    :line_items
      has_many    :payments
      has_many    :credit_notes
      
      validates_presence_of :date, :due_date
      validates_inclusion_of :type, :in => INVOICE_TYPES
      validates_inclusion_of :status, :in => INVOICE_STATUSES
      validates_inclusion_of :line_amount_types, :in => LINE_AMOUNT_TYPES
      validates_associated :contact
      validates_associated :line_items, :allow_blanks => true, :unless => proc { |invoice| invoice.approved? }
      validates_associated :line_items, :if => proc { |invoice| invoice.approved? }
      
      public
        
        # Helper method to check if the invoice has been approved.
        def approved?
          [ 'AUTHORISED', 'PAID', 'VOIDED' ].include? status
        end
        
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
            sum = (line_items || []).inject(BigDecimal.new('0')) { | sum, line_item | sum + line_item.line_amount }
            
            # If the default amount types are inclusive of 'tax' then remove the tax amount from this sub-total.
            sum -= total_tax if line_amount_types == 'Inclusive' 
            sum
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
        
        # Retrieve the PDF version of this invoice.
        # @param [String] filename optional filename to store the PDF in instead of returning the data.
        def pdf(filename = nil)
          parent.pdf(id, filename)
        end

        # Delete an approved invoice with no payments.
        def delete!
          delete_or_void_invoice!('DELETED')
        end

        # Void an approved invoice with no payments.
        def void!
          delete_or_void_invoice!('VOIDED')
        end

      protected

        def delete_or_void_authorised_invoice!(new_status)
          raise CannotChangeInvoiceStatus.new(record, new_status) unless self.payments.size == 0
          self.status = new_status
          self.save
        end
      
    end
    
  end
end
