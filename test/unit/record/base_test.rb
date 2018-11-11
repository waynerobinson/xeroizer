require 'test_helper'

class RecordBaseTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @contact = @client.Contact.build(:name => 'Test Contact Name ABC')
  end

  context "base record" do

    should "create new model instance from #new_model_class" do
      model_class = @contact.new_model_class("Invoice")
      assert_kind_of(Xeroizer::Record::InvoiceModel, model_class)
      assert_equal(@contact.parent.application, model_class.application)
      assert_equal('Invoice', model_class.model_name)
    end

    should "new_record? should be new on create" do
      assert_equal(true, @contact.new_record?)
    end

  end

  context "new_record? states" do

    should "new_record? should be false when loading data" do
      Xeroizer::OAuth.any_instance.stubs(:get).returns(stub(:plain_body => get_record_xml(:contact), :code => '200'))
      contact = @client.Contact.find('TESTID')
      assert_kind_of(Xeroizer::Record::Contact, contact)
      assert_equal(false, contact.new_record?)
    end

    should "new_record? should be false after successfully creating a record" do
      Xeroizer::OAuth.any_instance.stubs(:put).returns(stub(:plain_body => get_record_xml(:contact), :code => '200'))
      assert_equal(true, @contact.new_record?)
      assert_nil(@contact.contact_id)
      assert_equal(true, @contact.save, "Error saving contact: #{@contact.errors.inspect}")
      assert_equal(false, @contact.new_record?)
      assert(@contact.contact_id =~ GUID_REGEX, "@contact.contact_id is not a GUID, it is '#{@contact.contact_id}'")
    end

    should "new_record? should be false if we have specified a primary key" do
      contact = @client.Contact.build(:contact_id => 'ABC')
      assert_equal(false, contact.new_record?)

      contact = @client.Contact.build(:contact_number => 'CDE')
      assert_equal(true, contact.new_record?)

      contact = @client.Contact.build(:name => 'TEST NAME')
      assert_equal(true, contact.new_record?)
    end

  end

  context "about logging" do
    # Setup we only wish to do once:
    class ExampleRecordClass < Xeroizer::Record::Base
      def valid?; true; end
      def to_xml(b = nil); "<FakeRequest />" end
      string :id
    end
    class Xeroizer::Record::ExampleRecordClassModel < Xeroizer::Record::BaseModel; end

    # Setup before each test
    setup do
      @example_class = ExampleRecordClass
    end

    must "log the request and response xml when saving a new record" do
      Xeroizer::Logging::Log.expects(:info).once.with {|arg| arg =~ /\[CREATE SENT\]/}
      Xeroizer::Logging::Log.expects(:info).once.with {|arg| arg =~ /\[CREATE RECEIVED\]/}

      a_fake_parent = mock "Mock parent",
        :http_put => "<FakeResponse />",
        :parse_response => stub("Stub response", :response_items => []),
        :mark_dirty => nil,
        :create_method => :http_put,
        :mark_clean => nil,
        :application => nil

      an_example_instance = @example_class.new(a_fake_parent)

      an_example_instance.id = nil
      an_example_instance.save
    end

    must "log the request and response xml when updating an existing record" do
      Xeroizer::Logging::Log.expects(:info).once.with {|arg| arg =~ /\[UPDATE SENT\]/}
      Xeroizer::Logging::Log.expects(:info).once.with {|arg| arg =~ /\[UPDATE RECEIVED\]/}

      a_fake_parent = mock "Mock parent",
        :http_post => "<FakeResponse />",
        :parse_response => stub("Stub response", :response_items => []),
        :mark_dirty => nil,
        :mark_clean => nil,
        :application => nil

      an_example_instance = @example_class.new(a_fake_parent)

      an_example_instance.id = "phil's lunch box"
      an_example_instance.save
    end
  end

  context 'build' do

    should "raise an undefined method error with useful message" do
      assert_raise_message("undefined method `this_method_does_not_exist=' for #<Xeroizer::Record::Contact >") do
        @client.Contact.build(:this_method_does_not_exist =>  true)
      end
    end

  end

  context 'saving' do
    context 'invalid record' do
      setup do
        @contact.stubs(:valid?).returns(false)
      end

      must 'raise an exception saving with #save!' do
        assert_raise(Xeroizer::RecordInvalid) do
          @contact.save!
        end
      end

      must 'return false saving with #save' do
        assert_equal(false, @contact.save)
      end
    end

    context 'api error received' do
      setup do
        response = get_file_as_string('api_exception.xml')
        doc = Nokogiri::XML(response)
        exception = Xeroizer::ApiException.new(doc.root.xpath("Type").text,
                                               doc.root.xpath("Message").text,
                                               response,
                                               doc,
                                               '<FakeRequest />')

        @contact.stubs(:valid?).returns(true)
        @contact.stubs(:create).raises(exception)
        @contact.stubs(:update).raises(exception)
      end

      must 'raise an exception creating records with #save!' do
        @contact.stubs(:new_record?).returns(true)
        assert_raise(Xeroizer::ApiException) do
          @contact.save!
        end
      end

      must 'raise an exception updating records with #save!' do
        @contact.stubs(:new_record?).returns(false)
        assert_raise(Xeroizer::ApiException) do
          @contact.save!
        end
      end

      must 'return false creating records with #save' do
        @contact.stubs(:new_record?).returns(true)
        assert_equal(false, @contact.save)
      end

      must 'return false updating records with #save' do
        @contact.stubs(:new_record?).returns(false)
        assert_equal(false, @contact.save)
      end
    end
  end
end
