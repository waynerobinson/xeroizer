module Xeroizer
  module Report
    class AgedReceivablesByContact < Base

      public

        def total
          @_total_cache ||= summary.cell(:Total).value 
        end

        def total_paid
          @_total_paid_cache ||= summary.cell(:Paid).value
        end

        def total_credited
          @_total_credited_cache ||= summary.cell(:Credited).value
        end

        def total_due
          @_total_due_cache ||= summary.cell(:Due).value
        end

        def total_overdue
          return @_total_due_cache if @_total_due_cache
          
          now = Time.now
          @_total_due_cache = sum(:Due) do | row | 
            due_date = row.cell('Due Date').value
            due_date && due_date < now
          end
        end

        def sum(column_name, &block)
          sections.first.rows.inject(BigDecimal('0')) do | sum, row |
            sum += row.cell(column_name).value if row.class == Xeroizer::Report::Row && (block.nil? || block.call(row))
            sum
          end
        end
      
    end
  end
end
