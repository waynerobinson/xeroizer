module Xeroizer
  module Record
    
    class CreditNoteModel < BaseModel
        
      set_permissions :read, :write, :update
      
      include AttachmentModel::Extensions
      
      public

        # Retrieve the PDF version of the credit matching the `id`.
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
    
    class CreditNote < Base
      
      CREDIT_NOTE_STATUS = {
        'AUTHORISED' =>       'Approved credit_notes awaiting payment',
        'DELETED' =>          'Draft credit_notes that are deleted',
        'DRAFT' =>            'CreditNotes saved as draft or entered via API',
        'PAID' =>             'CreditNotes approved and fully paid',
        'SUBMITTED' =>        'CreditNotes entered by an employee awaiting approval',
        'VOIDED' =>           'Approved credit_notes that are voided'
      } unless defined?(CREDIT_NOTE_STATUS)
      CREDIT_NOTE_STATUSES = CREDIT_NOTE_STATUS.keys.sort
      
      CREDIT_NOTE_TYPE = {
        'ACCRECCREDIT' =>           'Accounts Receivable',
        'ACCPAYCREDIT' =>           'Accounts Payable'
      } unless defined?(CREDIT_NOTE_TYPE)
      CREDIT_NOTE_TYPES = CREDIT_NOTE_TYPE.keys.sort

      include Attachment::Extensions
      
      set_primary_key :credit_note_id
      set_possible_primary_keys :credit_note_id, :credit_note_number
      list_contains_summary_only true
      
      guid          :credit_note_id
      string        :credit_note_number
      string        :reference
      guid          :branding_theme_id
      string        :type
      date          :date
      date          :due_date
      string        :status
      string        :line_amount_types
      decimal       :sub_total, :calculated => true
      decimal       :total_tax, :calculated => true
      decimal       :total, :calculated => true
      datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      string        :currency_code
      decimal       :currency_rate
      datetime      :fully_paid_on_date
      boolean       :sent_to_contact
      decimal       :remaining_credit
      decimal       :applied_amount
      boolean       :has_attachments

      belongs_to    :contact
      has_many      :line_items
      has_many      :allocations
      
      validates_inclusion_of :type, :in => CREDIT_NOTE_TYPES
      validates_inclusion_of :status, :in => CREDIT_NOTE_STATUSES, :allow_blanks => true
      validates_associated :contact
      validates_associated :line_items
      validates_associated :allocations, :allow_blanks => true
      
      public
      
        # Access the contact name without forcing a download of
        # an incomplete, summary credit note.
        def contact_name
          attributes[:contact] && attributes[:contact][:name]
        end

        # Access the contact ID without forcing a download of an
        # incomplete, summary credit note.
        def contact_id
          attributes[:contact] && attributes[:contact][:contact_id]
        end      
      
        # Swallow assignment of attributes that should only be calculated automatically.
        def sub_total=(value);  raise SettingTotalDirectlyNotSupported.new(:sub_total);   end
        def total_tax=(value);  raise SettingTotalDirectlyNotSupported.new(:total_tax);   end
        def total=(value);      raise SettingTotalDirectlyNotSupported.new(:total);       end
      
        # Calculate sub_total from line_items.
        def sub_total(always_summary = false)
          if !always_summary && (new_record? || (!new_record? && line_items && line_items.size > 0))
            overall_sum = (line_items || []).inject(BigDecimal('0')) { | sum, line_item | sum + line_item.line_amount }
            
            # If the default amount types are inclusive of 'tax' then remove the tax amount from this sub-total.
            overall_sum -= total_tax if line_amount_types == 'Inclusive' 
            overall_sum
          else
            attributes[:sub_total]
          end
        end

        # Calculate total_tax from line_items.
        def total_tax(always_summary = false)
          if !always_summary && (new_record? || (!new_record? && line_items && line_items.size > 0))
            (line_items || []).inject(BigDecimal('0')) { | sum, line_item | sum + line_item.tax_amount }
          else
            attributes[:total_tax]
          end
        end

        # Calculate the total from line_items.
        def total(always_summary = false)
          unless always_summary
            sub_total + total_tax
          else
            attributes[:total]
          end
        end
        
        # Retrieve the PDF version of this credit note.
        # @param [String] filename optional filename to store the PDF in instead of returning the data.
        def pdf(filename = nil)
          parent.pdf(id, filename)
        end

        def save
          # Calling parse_save_response() on the credit note will wipe out
          # the allocations, so we have to manually preserve them.
          allocations_backup = self.allocations
          if super
            self.allocations = allocations_backup
            allocate unless self.allocations.empty?
            true
          end
        end

        def allocate
          if self.class.possible_primary_keys && self.class.possible_primary_keys.all? { | possible_key | self[possible_key].nil? }
            raise RecordKeyMustBeDefined.new(self.class.possible_primary_keys)
          end

          request = association_to_xml(:allocations)
          allocations_url = "#{parent.url}/#{CGI.escape(id)}/Allocations"

          log "[ALLOCATION SENT] (#{__FILE__}:#{__LINE__}) \r\n#{request}"
          response = parent.application.http_put(parent.application.client, allocations_url, request)
          log "[ALLOCATION RECEIVED] (#{__FILE__}:#{__LINE__}) \r\n#{response}"
          parse_save_response(response)
        end
    end

  end
end
