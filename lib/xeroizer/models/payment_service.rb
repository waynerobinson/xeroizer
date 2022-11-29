module Xeroizer
  module Record

    class PaymentServiceModel < BaseModel

      module Extensions
        def payment_services(branding_theme_id)
          application.PaymentService.payment_services(branding_theme_id)
        end

        def add_payment_service(branding_theme_id, payment_service_id)
          application.PaymentService.add_payment_service(branding_theme_id, payment_service_id)
        end
      end

      set_permissions :read, :write, :update

      def payment_services(branding_theme_id)
        response_xml = @application.http_get(@application.client, payment_services_endpoint(branding_theme_id))
        response = parse_response(response_xml)

        if (response_items = response.response_items) && response_items.size > 0
          response_items
        else
          []
        end
      end

      def add_payment_service(branding_theme_id, payment_service_id)
        xml = {
          PaymentService: {
            PaymentServiceID: payment_service_id
          }
        }.to_xml

        response_xml = @application.http_post(@application.client, payment_services_endpoint(branding_theme_id), xml)
        response = parse_response(response_xml)

        if (response_items = response.response_items) && response_items.size > 0
          response_items
        else
          []
        end
      end

      private

      def payment_services_endpoint(branding_theme_id)
        "#{@application.xero_url}/BrandingThemes/#{CGI.escape(branding_theme_id)}/PaymentServices"
      end

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
