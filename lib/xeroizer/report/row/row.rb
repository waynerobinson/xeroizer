require 'xeroizer/report/row/xml_helper'

module Xeroizer
  module Report
    class Row
      
      include RowXmlHelper
      
      attr_reader :report
      
      attr_accessor :type
      attr_accessor :title
      attr_accessor :rows
      attr_accessor :cells
      
      attr_accessor :parent
      
      attr_accessor :header
      
      public
      
        def initialize(report)
          @rows = []
          @cells = []
          @report = report
        end
        
        def header?;  @type == 'Header';      end
        def summary?; @type == 'SummaryRow';  end
        def section?; @type == 'Section';     end
        def row?;     @type == 'Row';         end
           
        def child?
          !parent.nil?
        end
        
        def parent?
          rows.size > 0
        end

        def cell(column_name)
          index = header.column_index(column_name)
          cells[index] if index >= 0
        end

    end
  end
end
