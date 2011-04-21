module Xeroizer
  module Report
    class HeaderRow < Row

        def column_index(column_name)
          cells.find_index { | cell | cell.value == column_name.to_s }
        end
        memoize :column_index
        
    end
  end
end
