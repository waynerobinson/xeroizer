module Xeroizer
  module Record

    class ContactGroupModel < BaseModel
      set_permissions :read
    end

    class ContactGroup < Base

      guid :contact_group_id
      string :name
      string :status

      has_many :contacts, :list_complete => true

    end

  end
end
