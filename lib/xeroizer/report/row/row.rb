require 'xeroizer/report/row/xml_helper'

module Xeroizer
  module Report
    class Row
      include RowXmlHelper

      attr_reader :report

      attr_accessor :type, :title, :rows, :cells, :parent, :header

      def initialize(report)
        @rows = []
        @cells = []
        @report = report
      end

      def header? = @type == 'Header'
      def summary? = @type == 'SummaryRow'
      def section? = @type == 'Section'
      def row? = @type == 'Row'

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
