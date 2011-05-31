require 'xeroizer/models/external_link'

module Xeroizer
  module Record
    
    class EmployeeModel < BaseModel
        
      set_permissions :read, :write, :update
        
    end
    
    class Employee < Base
          
      set_primary_key :employee_id
            
      guid    :employee_id
      string  :status
      string  :first_name
      string  :last_name

      belongs_to  :external_link

      validates_presence_of :first_name, :last_name
      
    end
    
  end
end