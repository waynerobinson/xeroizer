require 'test_helper'
require 'mocha/test_unit'

class TaxRateTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
  end

  should "have a primary key value of :name" do
    assert_equal :name, Xeroizer::Record::TaxRate.primary_key_name
  end

  should "build and save a tax rate with components via PUT" do
    @client.expects(:http_post).with { |client, url, body, extra_params|
      url == "https://api.xero.com/api.xro/2.0/TaxRates" &&
        body == expected_tax_rate_create_body
    }.returns(tax_rate_create_successful_response)

    tax_rate = @client.TaxRate.build(name: 'Test Tax Rate')
    tax_rate.add_tax_component(name: 'Tax Component', rate: '10.0')
    tax_rate.save

    assert_equal "Test Tax Rate", tax_rate.name
    assert_equal "ACTIVE", tax_rate.status
    assert tax_rate.tax_type.present?
    assert_equal 1, tax_rate.tax_components.size

    tax_component = tax_rate.tax_components.first
    assert_equal "Tax Component", tax_component.name
    assert_equal "10.0", tax_component.rate.to_s
  end

  should "allow reading of the ReportTaxType" do
    @client.expects(:http_get).with { |client, url, extra_params|
      url == "https://api.xero.com/api.xro/2.0/TaxRates"
    }.returns(tax_rate_get_response)
    rates = @client.TaxRate.all
    assert_equal "OUTPUT", rates.first.report_tax_type
  end

  should "allow GET with a filter on ReportTaxType" do
    expected_url    = "https://api.xero.com/api.xro/2.0/TaxRates"
    expected_params = {:where => 'ReportTaxType=="OUTPUT"'}

    @client.expects(:http_get).with { |client, url, extra_params|
      url == expected_url && extra_params == expected_params
    }.returns(tax_rate_get_response)

    @client.TaxRate.all(where: {report_tax_type: 'OUTPUT'})
  end

  def expected_tax_rate_create_body
    <<-EOS
<TaxRate>
  <Name>Test Tax Rate</Name>
  <TaxComponents>
    <TaxComponent>
      <Name>Tax Component</Name>
      <Rate>10.0</Rate>
    </TaxComponent>
  </TaxComponents>
</TaxRate>
    EOS
  end

  def tax_rate_create_successful_response
    <<-EOS
<Response xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Id>d1ec84aa-189f-4e08-b78f-ad62cf4935f4</Id>
  <Status>OK</Status>
  <ProviderName>Xero API Previewer</ProviderName>
  <DateTimeUTC>2014-07-02T19:26:53.3217153Z</DateTimeUTC>
  <TaxRates>
    <TaxRate>
      <Name>Test Tax Rate</Name>
      <TaxType>TAX018</TaxType>
      <CanApplyToAssets>true</CanApplyToAssets>
      <CanApplyToEquity>true</CanApplyToEquity>
      <CanApplyToExpenses>true</CanApplyToExpenses>
      <CanApplyToLiabilities>true</CanApplyToLiabilities>
      <CanApplyToRevenue>true</CanApplyToRevenue>
      <DisplayTaxRate>10.0000</DisplayTaxRate>
      <EffectiveRate>10.0000</EffectiveRate>
      <Status>ACTIVE</Status>
      <TaxComponents>
        <TaxComponent>
          <Name>Tax Component</Name>
          <Rate>10.0000</Rate>
          <IsCompound>false</IsCompound>
        </TaxComponent>
      </TaxComponents>
    </TaxRate>
  </TaxRates>
</Response>
    EOS
  end

  def tax_rate_get_response
    <<-EOS
<Response xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <Id>53715e8f-f080-4cd8-a077-1100c0512d44</Id>
  <Status>OK</Status>
  <ProviderName>Xero API Previewer</ProviderName>
  <DateTimeUTC>2014-10-28T15:39:58.5477531Z</DateTimeUTC>
  <TaxRates>
    <TaxRate>
      <Name>Tax on Sales</Name>
      <TaxType>OUTPUT</TaxType>
      <ReportTaxType>OUTPUT</ReportTaxType>
      <CanApplyToAssets>true</CanApplyToAssets>
      <CanApplyToEquity>true</CanApplyToEquity>
      <CanApplyToExpenses>true</CanApplyToExpenses>
      <CanApplyToLiabilities>true</CanApplyToLiabilities>
      <CanApplyToRevenue>true</CanApplyToRevenue>
      <DisplayTaxRate>9.2500</DisplayTaxRate>
      <EffectiveRate>9.2500</EffectiveRate>
      <Status>ACTIVE</Status>
      <TaxComponents>
        <TaxComponent>
          <Name>Sales Tax</Name>
          <Rate>9.2500</Rate>
          <IsCompound>false</IsCompound>
        </TaxComponent>
      </TaxComponents>
    </TaxRate>
  </TaxRates>
</Response>
    EOS
  end
end
