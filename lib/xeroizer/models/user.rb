module Xeroizer
  module Record

    class UserModel < BaseModel

      set_api_controller_name 'User'
      set_permissions :read

    end

    class User < Base

      set_primary_key :user_id

      guid         :user_id
      string       :email_address
      string       :first_name
      string       :last_name
      datetime_utc :updated_date_utc, :api_name => 'UpdatedDateUTC'
      boolean      :is_subscriber
      string       :organisation_role

    end

  end
end
