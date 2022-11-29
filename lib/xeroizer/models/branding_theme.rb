require "xeroizer/models/payment_service"

module Xeroizer
  module Record

    class BrandingThemeModel < BaseModel

      module Extensions
        def payment_services(branding_theme_id)
          parent.payment_services(branding_theme_id)
        end

        def add_payment_service(branding_theme_id, payment_service_id)
          parent.add_payment_service(branding_theme_id, payment_service_id)
        end
      end

      set_permissions :read, :write

      include PaymentServiceModel::Extensions

    end

    class BrandingTheme < Base

      include PaymentServiceModel::Extensions

      set_primary_key :branding_theme_id

      guid      :branding_theme_id
      string    :name
      integer   :sort_order
      datetime_utc  :created_date_utc, :api_name => 'CreatedDateUTC'

      # Use this method to retrieve the payment services applied to a branding theme.
      # GET https://api.xero.com/api.xro/2.0/BrandingThemes/{BrandingThemeID}/PaymentServices
      def payment_services
        parent.payment_services(branding_theme_id)
      end

      # Use this method to apply a payment service to a branding theme
      # POST https://api.xero.com/api.xro/2.0/BrandingThemes/{BrandingThemeID}/PaymentServices
      def add_payment_service(payment_service_id)
        parent.add_payment_service(branding_theme_id, payment_service_id)
      end
    end
  end
end
