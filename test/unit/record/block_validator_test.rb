require "test_helper"

class BlockValidatorTest < Test::Unit::TestCase
  def setup
    @fake_record_class = Class.new do
      attr_accessor :errors
      def initialize; @errors = []; end
    end
  end

  it "returns valid when block returns true" do
    record = @fake_record_class.new

    the_block_returning_true = Proc.new{ true }

    block_validator = Xeroizer::Record::Validator::BlockValidator.new(
      :name,
      :block => the_block_returning_true
    )

    block_validator.valid?(record)

    assert_empty record.errors, "Expected validation to pass. #{record.errors.inspect}"
  end

  it "returns invalid when block returns a non-null object" do
    record = @fake_record_class.new

    the_block_returning_true = Proc.new{ Object }

    block_validator = Xeroizer::Record::Validator::BlockValidator.new(
      :name,
      :block => the_block_returning_true
    )

    block_validator.valid?(record)

    assert_equal 1, record.errors.size, "Expected validation to fail with one error. #{record.errors.inspect}"
  end

  it "returns invalid when block returns false" do
    record = @fake_record_class.new

    the_block_returning_false = Proc.new{ false }

    block_validator = Xeroizer::Record::Validator::BlockValidator.new(
      :name,
      {
        :block => the_block_returning_false
      }
    )

    block_validator.valid?(record)

    assert_equal 1, record.errors.size, "Expected validation to fail with one error. #{record.errors.inspect}"
  end

  it "uses the message supplied when validation fails" do
    record = @fake_record_class.new

    the_block_returning_false = Proc.new{ false }

    expected_error = "Cornrows are usually a headwear mistake"

    block_validator = Xeroizer::Record::Validator::BlockValidator.new(
      :name,
      {
        :block => the_block_returning_false,
        :message => expected_error
      }
    )

    block_validator.valid?(record)

    assert_equal 1, record.errors.size,
      "Expected validation to fail with one error. #{record.errors.inspect}"
    assert_equal expected_error, record.errors.first[1],
      "There is an error, but it doesn't match"
  end

  it "uses a default message when validation fails and no message has been supplied" do
    record = @fake_record_class.new

    the_block_returning_false = Proc.new{ false }

    expected_error = "block condition failed"

    block_validator = Xeroizer::Record::Validator::BlockValidator.new(
      :name,
      {
        :block => the_block_returning_false
      }
    )

    block_validator.valid?(record)

    assert_equal 1, record.errors.size,
      "Expected validation to fail with one error. #{record.errors.inspect}"
    assert_equal expected_error, record.errors.first[1],
      "There is an error, but it doesn't match"
  end

  it "uses a default message when validation fails and message has been supplied as empty" do
    record = @fake_record_class.new

    the_block_returning_false = Proc.new{ false }

    expected_error = "block condition failed"

    block_validator = Xeroizer::Record::Validator::BlockValidator.new(
      :name,
      {
        :block => the_block_returning_false,
        :message => ""
      }
    )

    block_validator.valid?(record)

    assert_equal 1, record.errors.size,
      "Expected validation to fail with one error. #{record.errors.inspect}"
    assert_equal expected_error, record.errors.first[1],
      "There is an error, but it doesn't match"
  end
end
