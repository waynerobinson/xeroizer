require "xeroizer/models/attachment"

module Xeroizer
  module Record

    class InvoiceModel < BaseModel
      # To create a new invoice, use the folowing
      # $xero_client.Invoice.build(type: 'ACCREC', ..., contact: {name: 'Foo Bar'},...)
      # However for existing contacts, it is better to reference them by contactid (only)
      # see http://developer.xero.com/documentation/api/contacts/
      # $xero_client.Invoice.build(type: 'ACCREC', ..., contact: {contact_id: 'foo123-bar456-guid'},...)
      # Note that we are not making an api request to xero just to get the contact

      set_permissions :read, :write, :update

      include AttachmentModel::Extensions

      public

        # Retrieve the PDF version of the invoice matching the `id`.
        # @param [String] id invoice's ID.
        # @param [String] filename optional filename to store the PDF in instead of returning the data.
        def pdf(id, filename = nil)
          pdf_data = @application.http_get(@application.client, "#{url}/#{CGI.escape(id)}", :response => :pdf)
          if filename
            File.open(filename, "wb") { | fp | fp.write pdf_data }
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

      include Attachment::Extensions

      set_primary_key :invoice_id
      set_possible_primary_keys :invoice_id, :invoice_number
      list_contains_summary_only true

      guid         :invoice_id
      string       :invoice_number
      string       :reference
      guid         :branding_theme_id
      string       :url
      string       :type
      date         :date
      date         :due_date
      string       :status
      string       :line_amount_types
      decimal      :sub_total, :calculated => true
      decimal      :total_tax, :calculated => true
      decimal      :total, :calculated => true
      decimal      :amount_due
      decimal      :amount_paid
      decimal      :amount_credited
      datetime_utc :updated_date_utc, :api_name => 'UpdatedDateUTC'
      string       :currency_code
      decimal      :currency_rate
      datetime     :fully_paid_on_date
      datetime     :expected_payment_date
      boolean      :sent_to_contact
      boolean      :has_attachments

      belongs_to   :contact
      has_many     :line_items, :complete_on_page => true
      has_many     :payments
      has_many     :credit_notes

      validates_presence_of :date, :due_date, :unless => :new_record?
      validates_inclusion_of :type, :in => INVOICE_TYPES
      validates_inclusion_of :status, :in => INVOICE_STATUSES, :unless => :new_record?
      validates_inclusion_of :line_amount_types, :in => LINE_AMOUNT_TYPES, :unless => :new_record?
      validates_associated :contact
      validates_associated :line_items, :allow_blanks => true, :unless => :approved?
      validates_associated :line_items, :if => :approved?

      public

        # Access the contact name without forcing a download of
        # an incomplete, summary invoice.
        def contact_name
          attributes[:contact] && attributes[:contact][:name]
        end

        # Access the contact ID without forcing a download of an
        # incomplete, summary invoice.
        def contact_id
          attributes[:contact] && attributes[:contact][:contact_id]
        end

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

        def sub_total=(sub_total)
          @sub_total_is_set = true
          attributes[:sub_total] = sub_total
        end

        def total_tax=(total_tax)
          @total_tax_is_set = true
          attributes[:total_tax] = total_tax
        end

        def total=(total)
          @total_is_set = true
          attributes[:total] = total
        end

        # Calculate sub_total from line_items.
        def sub_total(always_summary = false)
          if !@sub_total_is_set && not_summary_or_loaded_record(always_summary)
            sum = (line_items || []).inject(BigDecimal.new('0')) { | sum, line_item | sum + line_item.line_amount }

            # If the default amount types are inclusive of 'tax' then remove the tax amount from this sub-total.
            sum -= total_tax if line_amount_types == 'Inclusive'
            sum
          else
            attributes[:sub_total]
          end
        end

        # Calculate total_tax from line_items.
        def total_tax(always_summary = false)
          if !@total_tax_is_set && not_summary_or_loaded_record(always_summary)
            (line_items || []).inject(BigDecimal.new('0')) { | sum, line_item | sum + line_item.tax_amount }
          else
            attributes[:total_tax]
          end
        end

        # Calculate the total from line_items.
        def total(always_summary = false)
          if !@total_is_set && not_summary_or_loaded_record(always_summary)
            sub_total + total_tax
          else
            attributes[:total]
          end
        end

        def not_summary_or_loaded_record(always_summary)
          !always_summary && loaded_record?
        end

        def loaded_record?
          new_record? ||
            (!new_record? && line_items && line_items.size > 0)
        end

        # Retrieve the PDF version of this invoice.
        # @param [String] filename optional filename to store the PDF in instead of returning the data.
        def pdf(filename = nil)
          parent.pdf(id, filename)
        end

        # Delete an approved invoice with no payments.
        def delete!
          change_status!('DELETED')
        end

        # Void an approved invoice with no payments.
        def void!
          change_status!('VOIDED')
        end

        # Approve a draft invoice
        def approve!
          change_status!('AUTHORISED')
        end

      protected

        def change_status!(new_status)
          raise CannotChangeInvoiceStatus.new(self, new_status) unless self.payments.size == 0
          self.status = new_status
          self.save
        end

    end

  end
end
