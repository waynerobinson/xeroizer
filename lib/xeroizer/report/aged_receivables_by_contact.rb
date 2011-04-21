module Xeroizer
  module Report
    class AgedReceivablesByContact < Base

      extend ActiveSupport::Memoizable

      public

        def total
          summary.cell(:Total).value 
        end

        def total_paid
          summary.cell(:Paid).value
        end

        def total_credited
          summary.cell(:Credited).value
        end

        def total_due
          summary.cell(:Due).value
        end

        def total_overdue
          now = Time.now
          sum(:Due) do | row | 
            due_date = row.cell('Due Date').value
            due_date && due_date < now
          end
        end

        def sum(column_name, &block)
          sections.first.rows.inject(BigDecimal.new('0')) do | sum, row |
            cell = row.cell(column_name)
            sum += row.cell(column_name).value if row.class == Xeroizer::Report::Row && (block.nil? || block.call(row))
            sum
          end
        end
        memoize :total, :total_paid, :total_credited, :total_due, :total_overdue, :sum
      
    end
  end
end
