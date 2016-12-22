require 'xeroizer/application_http_proxy' 
require 'xeroizer/report/base'
require 'xeroizer/report/aged_receivables_by_contact'

module Xeroizer
  module Report
    class Factory
      
      include ApplicationHttpProxy

      attr_reader :application
      attr_reader :report_type
      attr_reader :response_xml
      
      public
      
        def initialize(application, report_type)
          @application = application
          @report_type = report_type
        end
      
        # Retreive a report with the `options` as a hash containing
        # valid query-string parameters to pass to the API.
        def get(options = {})
          @response_xml = options[:cache_file] ? File.read(options[:cache_file]) : http_get(options)
          response = Response.parse(response_xml, options) do | response, elements |
            parse_reports(response, elements)
          end
          response.response_items.first # there is is only one
        end
      
        def api_controller_name
          "Reports/#{report_type}"
        end

        def klass
          begin
            @_klass_cache ||= Xeroizer::Report.const_get(report_type, false)
          rescue NameError => ex # use default class
            Base
          end
        end

      protected
              
        def parse_reports(response, elements)
          elements.each do | element |
            response.response_items << klass.build_from_node(element, self)
          end
        end
        
    end
  end
end
