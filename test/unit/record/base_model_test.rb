require 'test_helper'

class RecordBaseModelTest < Test::Unit::TestCase
  include TestHelper
  
  class AppleModel < Xeroizer::Record::BaseModel
    set_api_controller_name 'AppleController'
    set_permissions :read, :write
  end
  
  class PearModel < Xeroizer::Record::BaseModel
    set_api_controller_name 'PearController'
    set_permissions :read
  end
  
  class OrangeModel < Xeroizer::Record::BaseModel
    set_permissions :read, :write, :update
  end
  
  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @apple_model = AppleModel.new(@client, 'Apple')
    @pear_model = PearModel.new(@client, 'Pear')
    @orange_model = OrangeModel.new(@client, 'Orange')
  end
  
  context "RecordModel.api_controller_name" do
    
    should "api_controller_name should default to pluralized model name" do
      assert_equal('Oranges', @orange_model.api_controller_name)
    end
    
    should "set_api_controller_name should set the base controller name used by Xero" do
     assert_equal('AppleController', @apple_model.api_controller_name)
     assert_equal('PearController', @pear_model.api_controller_name)
    end
    
  end
  
  context "model permssions" do
    
    should "save permissions correctly" do
      assert_equal(%w(read write), @apple_model.class.permissions.keys.map(&:to_s).sort)
      assert_equal(%w(read), @pear_model.class.permissions.keys.map(&:to_s).sort)
      assert_equal(%w(read update write), @orange_model.class.permissions.keys.map(&:to_s).sort)
    end
    
  end

  context "InvalidPermissionError" do
    should "also be catchable by the name 'InvaidPermissionError' for historical reasons" do
      assert_raise(Xeroizer::Record::BaseModel::InvaidPermissionError) do
        raise Xeroizer::Record::BaseModel::InvalidPermissionError
      end
    end
  end

end
