module Xeroizer
  module Record
    
    class ManualJournalModel < BaseModel
        
      set_permissions :read, :write, :update
                  
    end
    
    class ManualJournal < Base
      
      JOURNAL_STATUS = {
        'DRAFT' =>      'Draft',
        'APPROVED' =>   'Approved'
      } unless defined?(INVOICE_TYPE)
      JOURNAL_STATUSES = JOURNAL_STATUS.keys.sort
            
      set_primary_key :manual_journal_id
      set_possible_primary_keys :manual_journal_id
      list_contains_summary_only true
      
      guid      :manual_journal_id
      date      :date
      string    :status
      string    :line_amount_types
      string    :narration
      datetime  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      
      has_many  :journal_lines, :model_name => 'ManualJournalLine'
      
      validates_presence_of :narration
      validates_associated :journal_lines
      
      # Can only create/update manual journals in DRAFT status
      validates_inclusion_of :status, :in => %w(DRAFT)
      
      public
      
    end
    
  end
end