module Xeroizer
  module Report
    class AgedReceivablesByContact < Base

      public

        def total
          @_total_cache ||= sum(:Total)
        end

        def total_paid
          @_total_paid_cache ||= sum(:Paid)
        end

        def total_credited
          @_total_credited_cache ||= sum(:Credited)
        end

        def total_due
          @_total_due_cache ||= sum(:Due)
        end

        def total_overdue
          now = Time.now
          @_total_overdue_cache ||= sum(:Due) do | row | 
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
      
    end
  end
end
