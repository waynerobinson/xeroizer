module Xeroizer
  module Record
    
    class InvoiceReminderModel < BaseModel
      
      set_api_controller_name 'InvoiceReminders/Settings'
    
      set_permissions :read 
    
    end
    
    class InvoiceReminder < Base

      boolean   :enabled

    end
    
  end
end