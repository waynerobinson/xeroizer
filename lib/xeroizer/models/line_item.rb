require 'xeroizer/models/account'
require 'xeroizer/models/line_amount_type'

module Xeroizer
  module Record
    class LineItemModel < BaseModel

    end

    class LineItem < Base
      TAX_TYPE = Account::TAX_TYPE unless defined?(TAX_TYPE)

      string  :item_code
      string  :description
      decimal :quantity
      decimal :unit_amount
      string  :account_code
      string  :tax_type
      decimal :tax_amount
      decimal :line_amount, :calculated => true
      decimal :discount_rate
      decimal :discount_amount
      string  :line_item_id

      has_many  :tracking, :model_name => 'TrackingCategoryChild'

      def initialize(parent)
        super(parent)
        @line_amount_set = false
      end

      def line_amount=(line_amount)
        @line_amount_set = true
        attributes[:line_amount] = line_amount
      end

      # Calculate the line_total (if there is a quantity and unit_amount).
      # Description-only lines have been allowed since Xero V2.09.
      def line_amount(summary_only = false)
        return attributes[:line_amount] if summary_only || @line_amount_set

        if quantity && unit_amount
          total = coerce_numeric(quantity) * coerce_numeric(unit_amount)
          if discount_rate.nonzero?
            BigDecimal((total * ((100 - discount_rate) / 100)).to_s).round(2)
          elsif discount_amount
            BigDecimal(total - discount_amount).round(2)
          else
            BigDecimal(total.to_s).round(2)
          end
        end
      end

      private

      def coerce_numeric(number)
        return number if number.is_a? Numeric
        BigDecimal(number)
      end

    end

  end
end
