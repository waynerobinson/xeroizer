require "test_helper"

class BlockValidatorTest < Test::Unit::TestCase
  def setup
    @fake_record_class = Class.new do
      attr_accessor :name, :errors
      def initialize(name)
        @errors = []
        @name = name
      end
    end
  end

  it "returns valid when block returns true" do
    record = @fake_record_class.new "Orange"

    the_block_validating_name_equals_orange = Proc.new{ name == "Orange" }

    block_validator = Xeroizer::Record::Validator::BlockValidator.new(
      :name,
      :block => the_block_validating_name_equals_orange
    )

    block_validator.valid?(record)

    assert_empty record.errors, "Expected validation to pass. #{record.errors.inspect}"
  end

  it "fails if no block is supplied"
end
