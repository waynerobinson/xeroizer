require 'xeroizer/models/account'
require 'xeroizer/models/line_amount_type'

module Xeroizer
  module Record
    class ContactPersonModel < BaseModel
      set_xml_root_name "ContactPersons"
    end

    class ContactPerson < Base

      string  :first_name
      string  :last_name
      string  :email_address
      boolean :include_in_emails

    end

  end
end
