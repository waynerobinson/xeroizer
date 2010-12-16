module Xeroizer
  module Record
    
    class JournalClass < BaseClass
        
      set_permissions :read
      
    end
    
    class Journal < Base
      
      string    :journal_id, :api_name => 'JournalID'
      date      :journal_date, :internal_name => :date
      string    :journal_number
      datetime  :created_date_utc, :api_name => 'CreatedDateUTC'
      string    :reference
      
      has_many  :journal_lines
       
    end
    
  end
end