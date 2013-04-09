# Copyright (c) 2008 Tim Connor <tlconnor@gmail.com>
# 
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

module Xeroizer
  class Response
    
    attr_accessor :id, :status, :errors, :provider, :date_time, :response_items, :request_params, :request_xml, :response_xml
    
    class << self
      
      # Parse the response retreived during any request.
      def parse(raw_response, request = {}, options = {}, &block)
        response = Xeroizer::Response.new
        response.response_xml = raw_response
      
        doc = Nokogiri::XML(raw_response) { | cfg | cfg.noblanks }
      
        # check for responses we don't understand
        raise Xeroizer::UnparseableResponse.new(doc.root.name) unless doc.root.name == 'Response'
      
        doc.root.elements.each do | element |
                    
          # Text element
          if element.children && element.children.size == 1 && element.children.first.text?
            case element.name
              when 'Id'           then response.id = element.text
              when 'Status'       then response.status = element.text
              when 'ProviderName' then response.provider = element.text
              when 'DateTimeUTC'  then response.date_time = Time.parse(element.text)
            end
          
          # Records in response
          elsif element.children && element.children.size > 0
            yield(response, element.children, element.children.first.name)
          end
        end
      
        response
      end
      
    end
    
    public
    
      def initialize
        @response_items = []
      end
    
      def success?
        status == 'OK'
      end
      
      def error
        errors.blank? ? nil : errors[0]
      end
      
  end
end