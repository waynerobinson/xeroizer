require 'xeroizer/application_http_proxy' 
require 'xeroizer/report/base'
require 'xeroizer/report/aged_receivables_by_contact'

module Xeroizer
  module Report
    class Factory
      
      extend ActiveSupport::Memoizable
      include ApplicationHttpProxy

      attr_reader :application
      attr_reader :report_type
      
      public
      
        def initialize(application, report_type)
          @application = application
          @report_type = report_type
        end
      
        # Retreive a report with the `options` as a hash containing
        # valid query-string parameters to pass to the API.
        def get(options = {})
          response_xml = options[:cache_file] ? File.read(options[:cache_file]) : http_get(options)          
          Response.parse(response_xml, options) do | response, elements |
            parse_reports(response, elements)
          end.first # there is is only one
        end
      
        def api_controller_name
          "Reports/#{report_type}"
        end

        def klass
          begin
            Xeroizer::Report.const_get(report_type)
          rescue NameError => ex # use default class
            Base
          end
        end
        memoize :klass

      protected
              
        def parse_reports(response, elements)
          elements.each do | element |
            response.response_items << klass.build_from_node(element, self)
          end
        end
        
    end
  end
end
