require 'unit_test_helper'

class ConnectionTest < UnitTestCase
  include TestHelper

  setup do
    @client = Xeroizer::OAuth2Application.new("client id", "client secret", access_token: "access token")
  end

  context "when the request succeeds" do
    setup do
      stub_request(:get, "https://api.xero.com/connections").to_return(
        body: [
          {
            id: "fe4cd81c-624a-4506-ab18-11c656742436",
            tenantId: "c84e0419-ade8-4296-9794-289876d4bc22",
            tenantType: "ORGANISATION",
            createdDateUtc: "2019-12-13T18:10:43.3063640",
            updatedDateUtc: "2019-12-13T18:10:43.3084790"
          },
          {
            id: "fe4cd81c-624a-4506-ab18-11c656742436",
            tenantId: "c84e0419-ade8-4296-9794-289876d4bc22",
            tenantType: "ORGANISATION",
            createdDateUtc: "2019-12-13T18:10:43.3063640",
            updatedDateUtc: "2019-12-13T18:10:43.3084790"
          }
        ].to_json
      )
    end

    it 'returns connections using the passed client' do
      result = Xeroizer::Connection.current_connections(@client.client)
      assert_equal 2, result.count
      assert_equal "c84e0419-ade8-4296-9794-289876d4bc22", result.first.tenant_id
    end
  end

  context 'when the request fails' do
    setup do
      @body = {
        title: "Unauthorized",
        status: 401,
        detail: "AuthenticationUnsuccessful",
        instance: "e1d2cb91-82bf-41a5-84dd-fe6a5c6f070c"
      }.to_json

      stub_request(:get, "https://api.xero.com/connections").to_return(
        status: 401,
        body: @body
      )
    end

    it 'raises token_invalid error' do
      assert_raises(Xeroizer::OAuth::TokenInvalid, @body) {
        Xeroizer::Connection.current_connections(@client.client)
      }
    end
  end
end
