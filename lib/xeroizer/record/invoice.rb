module Xeroizer
  module Record
    
    class InvoiceClass < BaseClass
        
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
      
      string    :invoice_id
      string    :invoice_number
      string    :reference
      string    :branding_theme_id
      string    :url
      string    :type
      date      :date
      date      :due_date
      string    :status
      string    :line_amount_types
      decimal   :sub_total
      decimal   :total_tax
      decimal   :total
      decimal   :amount_due
      decimal   :amount_paid
      decimal   :amount_credited
      datetime  :updated_date_utc
      string    :currency_code
      datetime  :fully_paid_on_date
      
      belongs_to  :contact
      has_many    :line_items
      has_many    :payments
      
    end
    
  end
end