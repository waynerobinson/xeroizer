require 'unit_test_helper'

class AddressTest < Test::Unit::TestCase
  include TestHelper

  def setup
    @client = Xeroizer::PublicApplication.new(CONSUMER_KEY, CONSUMER_SECRET)
    @contact = @client.Contact.build
  end

  def build_valid_address
    @contact.add_address({
      :type => "DEFAULT",
      :address_line1 => "Baker street",
      :address_line2 => "221",
      :address_line3 => "Appartment: B",
      :address_line4 => "abcdefgh",
      :city => "London",
      :region => "Marylebone",
      :postal_code => "NW1 6XE",
      :country => "UK",
      :attention_to => "Mr Sherlock Holmes"
    })
  end

  def generate_random_string(size)
    charset = %w{A C D E F G H J K M N P Q R T V W X Y Z}
    (0...size).map{ charset.to_a[rand(charset.size)] }.join
  end

   context "validators" do

    should "allow valid address with valid attributes" do
      address = build_valid_address
      assert_equal(true, address.valid?)
    end

    should "not allow address_line1 to be longer than 500 characters" do
      address = build_valid_address
      address.line1 = generate_random_string(501)
      assert_equal(false, address.valid?)
    end

    should "not allow address_line2 to be longer than 500 characters" do
      address = build_valid_address
      address.line2 = generate_random_string(501)
      assert_equal(false, address.valid?)
    end
    should "not allow address_line3 to be longer than 500 characters" do
      address = build_valid_address
      address.line3 = generate_random_string(501)
      assert_equal(false, address.valid?)
    end

    should "not allow address_line4 to be longer than 500 characters" do
      address = build_valid_address
      address.line4 = generate_random_string(501)
      assert_equal(false, address.valid?)
    end


    should "not allow city to be longer than 255 characters" do
      address = build_valid_address
      address.city = generate_random_string(256)
      assert_equal(false, address.valid?)
    end

    should "not allow region to be longer than 255 characters" do
      address = build_valid_address
      address.region = generate_random_string(256)
      assert_equal(false, address.valid?)
    end

    should "not allow postal_code to be longer than 50 characters" do
      address = build_valid_address
      address.postal_code = generate_random_string(51)
      assert_equal(false, address.valid?)
    end

    should "not allow country to be longer than 50 characters" do
      address = build_valid_address
      address.country = generate_random_string(51)
      assert_equal(false, address.valid?)
    end

    should "not allow attention_to to be longer than 255 characters" do
      address = build_valid_address
      address.attention_to = generate_random_string(256)
      assert_equal(false, address.valid?)
    end
  end
end
