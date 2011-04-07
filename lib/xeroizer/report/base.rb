require 'xeroizer/report/base'
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
      
      attr_accessor :id
      attr_accessor :name
      attr_accessor :type
      attr_accessor :titles
      attr_accessor :date
      attr_accessor :updated_at
      
      attr_accessor :rows
      
      attr_accessor :header
      attr_accessor :summary
      attr_accessor :sections
            
      public
      
        def initialize(factory)
          @titles = []
          @rows = []
          @sections = []
          @factory = factory
        end
      
      protected
                  
    end
  end
end
