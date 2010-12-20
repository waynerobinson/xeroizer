module Xeroizer
  module Record
    
    class CreditNoteModel < BaseModel
        
      set_permissions :read, :write, :update
      
    end
    
    class CreditNote < Base
      
      CREDIT_NOTE_STATUS = {
        'AUTHORISED' =>       'Approved credit_notes awaiting payment',
        'DELETED' =>          'Draft credit_notes that are deleted',
        'DRAFT' =>            'CreditNotes saved as draft or entered via API',
        'PAID' =>             'CreditNotes approved and fully paid',
        'SUBMITTED' =>        'CreditNotes entered by an employee awaiting approval',
        'VOID' =>             'Approved credit_notes that are voided'
      } unless defined?(CREDIT_NOTE_STATUS)
      CREDIT_NOTE_STATUSES = CREDIT_NOTE_STATUS.keys.sort
      
      CREDIT_NOTE_TYPE = {
        'ACCRECCREDIT' =>           'Accounts Receivable',
        'ACCPAYCREDIT' =>           'Accounts Payable'
      } unless defined?(CREDIT_NOTE_TYPE)
      CREDIT_NOTE_TYPES = CREDIT_NOTE_TYPE.keys.sort
      
      set_primary_key :credit_note_id
      set_possible_primary_keys :credit_note_id, :credit_note_number
      list_contains_summary_only true
      
      string    :credit_note_id, :api_name => 'CreditNoteID'
      string    :credit_note_number
      string    :reference
      string    :type
      date      :date
      date      :due_date
      string    :status
      string    :line_amount_types
      decimal   :sub_total, :calculated => true
      decimal   :total_tax, :calculated => true
      decimal   :total, :calculated => true
      datetime  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      string    :currency_code
      datetime  :fully_paid_on_date
      
      belongs_to  :contact
      has_many    :line_items
      
      validates_inclusion_of :type, :in => CREDIT_NOTE_TYPES
      validates_inclusion_of :status, :in => CREDIT_NOTE_STATUSES, :allow_blanks => true
      validates_associated :contact
      validates_associated :line_items
      
      public
      
        # Swallow assignment of attributes that should only be calculated automatically.
        def sub_total=(value);  raise SettingTotalDirectlyNotSupported.new(:sub_total);   end
        def total_tax=(value);  raise SettingTotalDirectlyNotSupported.new(:total_tax);   end
        def total=(value);      raise SettingTotalDirectlyNotSupported.new(:total);       end
      
        # Calculate sub_total from line_items.
        def sub_total
          if new_record? || complete_record_downloaded?
            (line_items || []).inject(BigDecimal.new('0')) { | sum, line_item | sum + line_item.line_amount }
          else
            attributes[:sub_total]
          end
        end
      
        # Calculate total_tax from line_items.
        def total_tax
          if new_record? || complete_record_downloaded?
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