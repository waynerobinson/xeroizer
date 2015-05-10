module Xeroizer
  module Record
    
    class ManualJournalModel < BaseModel
        
      set_permissions :read, :write, :update
                  
    end
    
    class ManualJournal < Base
      
      JOURNAL_STATUS = {
        'DRAFT' =>      'Draft',
        'POSTED' =>     'Posted'
      } unless defined?(JOURNAL_STATUS)
      JOURNAL_STATUSES = JOURNAL_STATUS.keys.sort
            
      set_primary_key :manual_journal_id
      set_possible_primary_keys :manual_journal_id
      list_contains_summary_only true
      
      guid          :manual_journal_id
      date          :date
      string        :status
      string        :line_amount_types
      string        :narration
      string        :url
      string        :external_link_provider_name # only seems to be read-only at the moment
      boolean       :show_on_cash_basis_reports
      datetime_utc  :updated_date_utc, :api_name => 'UpdatedDateUTC'
      
      has_many      :journal_lines, :model_name => 'ManualJournalLine', :complete_on_page => true
      
      validates_presence_of :narration
      validates_associated :journal_lines
            
      public
      
    end
    
  end
end
