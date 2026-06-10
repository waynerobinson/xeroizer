require 'xeroizer/report/cell_xml_helper'

module Xeroizer
  module Report
    class Cell
      include CellXmlHelper

      attr_accessor :value, :attributes

      def initialize
        @attributes = {}
      end

      # Return first attribute's ID in the hash. Assumes there is only one as hashes get out of order.
      # In all cases I've seen so far there is only one attribute returned.
      def attribute_id
        @attributes.each { |id, _value| return id }
      end

      # Return first attribute's value in the hash. Assumes there is only one as hashes get out of order.
      # In all cases I've seen so far there is only one attribute returned.
      def attribute_value
        @attributes.each { |_id, value| return value }
      end
    end
  end
end
