module Xeroizer
  module Report
    class HeaderRow < Row

        def column_index(column_name)
          @_column_index_cache ||= {}
          @_column_index_cache[column_name] ||= cells.find_index { | cell | cell.value == column_name.to_s }
        end
        
    end
  end
end
