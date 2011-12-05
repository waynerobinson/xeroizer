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

    the_block_returning_true = Proc.new{ true }

    block_validator = Xeroizer::Record::Validator::BlockValidator.new(
      :name,
      :block => the_block_returning_true
    )

    block_validator.valid?(record)

    assert_empty record.errors, "Expected validation to pass. #{record.errors.inspect}"
  end

  it "returns invalid when block returns false" do
    record = @fake_record_class.new "Orange"

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
end
