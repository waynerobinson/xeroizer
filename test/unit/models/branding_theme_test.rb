# frozen_string_literal: true

require 'unit_test_helper'

# BrandingTheme#add_payment_service POSTs a small PaymentService body to Xero.
class BrandingThemeTest < UnitTestCase
  include TestHelper

  OK_RESPONSE = '<Response><Status>OK</Status></Response>'
  PS_URL = 'https://api.xero.com/api.xro/2.0/BrandingThemes/BT-1/PaymentServices'

  def setup
    super
    @application = Xeroizer::OAuth2Application.new(
      CLIENT_ID, CLIENT_SECRET, tenant_id: TENANT_ID, access_token: ACCESS_TOKEN
    )
  end

  # The gem transmits write bodies as the form param `xml=<url-encoded XML>`;
  # recover the XML document the method actually built.
  def posted_xml(req)
    CGI.unescape(req.body.sub(/\Axml=/, ''))
  end

  context '#add_payment_service' do
    should 'POST a <PaymentService> body with the payment service id' do
      stub_request(:post, PS_URL).to_return(status: 200, body: OK_RESPONSE)

      @application.BrandingTheme.add_payment_service(id: 'BT-1', payment_service_id: 'PS-1')

      xml = nil
      assert_requested(:post, PS_URL) do |req|
        xml = posted_xml(req)
        true
      end

      doc = Nokogiri::XML(xml)
      assert_equal 'PaymentService', doc.root.name,
                   "expected a <PaymentService> root element, got: #{xml.inspect}"
      assert_equal 'PS-1', doc.at_xpath('/PaymentService/PaymentServiceID')&.text
      # Guard against a revert to Hash#to_xml, which would wrap the body in a <hash> root.
      refute_includes xml, '<hash>',
                      'unexpected <hash> wrapper in the request body'
      refute_includes xml, '<?xml',
                      'request body should not carry an XML declaration'
    end

    should 'forward a record-level call to the model' do
      url = 'https://api.xero.com/api.xro/2.0/BrandingThemes/BT-2/PaymentServices'
      stub_request(:post, url).to_return(status: 200, body: OK_RESPONSE)

      theme = @application.BrandingTheme.build(branding_theme_id: 'BT-2')
      theme.add_payment_service('PS-2')

      xml = nil
      assert_requested(:post, url) do |req|
        xml = posted_xml(req)
        true
      end
      assert_equal 'PS-2', Nokogiri::XML(xml).at_xpath('/PaymentService/PaymentServiceID')&.text
    end
  end
end
