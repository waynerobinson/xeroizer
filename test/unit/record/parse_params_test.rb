require 'unit_test_helper'

module Xeroizer
  module Record

    class ParseParamTestModel < BaseModel
    end

    class ParseParamTest < Base

      set_primary_key :primary_key_id

      guid      :primary_key_id
      string    :string1
      boolean   :boolean1
      integer   :integer1
      decimal   :decimal1
      date      :date1
      datetime  :datetime1

    end

  end
end

class ParseParamsTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @model = Xeroizer::Record::ParseParamTestModel.new(@client, "ParseParamTest")
  end

  context "should return valid and filtered params" do
    should "filter unsupported keys" do
      params = @model.send(:parse_params, {
        :should_be_filtered_out => 'should be filtered',
        :modified_since => Date.parse("2010-01-05"),
        :include_archived => true,
        :order => :order,
        :where => 'where string',
        :IDs => ['29ed7958-0466-486d-bf57-3fd966ea37d7', 'd561892a-9023-498c-a28d-c626ed3940d8'],
        :InvoiceNumbers => 'INV-0034,INV-0035,INV-0036,INV-0037',
        :ContactIDs => 'b919a496-1a1c-4fc6-b6ef-8c561e0dd8c2,8289cca4-90a9-466b-95f3-f0adf351b2ac',
        :Statuses => ['DRAFT', nil, 'SUBMITTED'],
        :offset => 100,
        :page => 2
      })

      params.assert_valid_keys(:ModifiedAfter, :includeArchived, :order, :where,
                               :IDs, :InvoiceNumbers, :ContactIDs, :Statuses,
                               :offset, :page)
      assert_equal(params[:IDs], '29ed7958-0466-486d-bf57-3fd966ea37d7,d561892a-9023-498c-a28d-c626ed3940d8')
      assert_equal(params[:InvoiceNumbers], 'INV-0034,INV-0035,INV-0036,INV-0037')
      assert_equal(params[:ContactIDs], 'b919a496-1a1c-4fc6-b6ef-8c561e0dd8c2,8289cca4-90a9-466b-95f3-f0adf351b2ac')
      assert_equal(params[:Statuses], 'DRAFT,,SUBMITTED')
    end
  end
end
