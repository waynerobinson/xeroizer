require 'xeroizer/report/cell'
require 'xeroizer/report/row/row'
require 'xeroizer/report/row/header'
require 'xeroizer/report/row/section'
require 'xeroizer/report/row/summary'
require 'xeroizer/report/xml_helper'

module Xeroizer
  module Report
    class Base
      include XmlHelper

      attr_reader :factory

      attr_accessor :id, :name, :type, :titles, :date, :updated_at, :rows, :header, :summary, :sections

      def initialize(factory)
        @titles = []
        @rows = []
        @sections = []
        @factory = factory
      end
    end
  end
end
