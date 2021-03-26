require "xeroizer/models/payment_service"

module Xeroizer
  module Record

    class BrandingThemeModel < BaseModel

      set_permissions :read, :write

      public

      def payment_services(id)
        @payment_services ||= @application.http_get(@application.client, payment_services_endpoint(id))
      end

      def add_payment_service(id:, payment_service_id:)
        xml = {
          PaymentService: {
            PaymentServiceID: payment_service_id
          }
        }.to_xml

        @application.http_post(@application.client, payment_services_endpoint(id), xml)
      end

      private

      def payment_services_endpoint(id)
        "#{url}/#{id}/PaymentServices"
      end

    end

    class BrandingTheme < Base

      set_primary_key :branding_theme_id

      guid      :branding_theme_id
      string    :name
      integer   :sort_order
      datetime_utc  :created_date_utc, :api_name => 'CreatedDateUTC'

      # Unfortunately, this part of the API does not work the same as the rest.
      # You cannot POST child records to Branding Themes.
      #
      # The endpoints are:
      # GET /BrandingThemes/{BrandingThemeID}/PaymentServices
      # POST /BrandingThemes/{BrandingThemeID}/PaymentServices
      #
      # has_one :payment_service, :model_name => 'PaymentService', :list_complete => true

      def payment_services
        parent.payment_services(id)
      end

      def add_payment_service(payment_service_id)
        parent.add_payment_service(id: id, payment_service_id: payment_service_id)
      end
    end

  end
end
