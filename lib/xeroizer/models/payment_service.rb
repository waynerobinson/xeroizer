module Xeroizer
  module Record

    class PaymentServiceModel < BaseModel

      set_permissions :read, :write, :update

    end

    class PaymentService < Base

      set_primary_key :payment_service_id

      guid :payment_service_id
      string :payment_service_name
      string :payment_service_url
      string :payment_service_type
      string :pay_now_text

    end
  end
end
