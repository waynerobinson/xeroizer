module Xeroizer
  module Record
    class LineItemSum
      def self.total(line_items)
        sub_total(line_items) + total_tax(line_items)
      end

      def self.sub_total(line_items)
        line_items.inject(BigDecimal("0")) do |sum, item|
          sum += BigDecimal(item.line_amount.to_s).round(2)
        end
      end

      def self.total_tax(line_items)
        line_items.inject(BigDecimal("0")) do |sum, item|
          sum += BigDecimal(item.tax_amount.to_s).round(2)
        end
      end
    end
  end
end
