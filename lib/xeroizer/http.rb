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
  module Http
    
    ACCEPT_MIME_MAP = {
      :pdf  => 'application/pdf',
      :json => 'application/json'
    }
    
    # Shortcut method for #http_request with `method` = :get.
    #
    # @param [OAuth] client OAuth client
    # @param [String] url URL of request
    # @param [Hash] extra_params extra query string parameters.
    def http_get(client, url, extra_params = {})
      http_request(client, :get, url, nil, extra_params)
    end

    # Shortcut method for #http_request with `method` = :post.
    #
    # @param [OAuth] client OAuth client
    # @param [String] url URL of request
    # @param [String] body XML message to post.
    # @param [Hash] extra_params extra query string parameters.
    def http_post(client, url, body, extra_params = {})
      http_request(client, :post, url, body, extra_params)
    end

    # Shortcut method for #http_request with `method` = :put.
    #
    # @param [OAuth] client OAuth client
    # @param [String] url URL of request
    # @param [String] body XML message to put.
    # @param [Hash] extra_params extra query string parameters.
    def http_put(client, url, body, extra_params = {})
      http_request(client, :put, url, body, extra_params)
    end
    
    private
    
      def http_request(client, method, url, body, params = {})
        # headers = {'Accept-Encoding' => 'gzip, deflate'}

        headers = { 'charset' => 'utf-8' }

        if method != :get
          headers['Content-Type'] ||= "application/x-www-form-urlencoded"
        end

        # HAX.  Xero completely misuse the If-Modified-Since HTTP header.
        headers['If-Modified-Since'] = params.delete(:ModifiedAfter).utc.strftime("%Y-%m-%dT%H:%M:%S") if params[:ModifiedAfter]
        
        # Allow 'Accept' header to be specified with :accept parameter.
        # Valid values are :pdf or :json.
        if params[:response]
          response_type = params.delete(:response)
          headers['Accept'] = case response_type
            when Symbol then  ACCEPT_MIME_MAP[response_type]
            else              response_type
          end
        end
        
        if params.any?
          url += "?" + params.map {|key,value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"}.join("&")
        end

        uri   = URI.parse(url)

        attempts = 0

        begin
          attempts += 1
          logger.info("\n== [#{Time.now.to_s}] XeroGateway Request: #{method.to_s.upcase} #{uri.request_uri} ") if self.logger

          response = case method
            when :get   then    client.get(uri.request_uri, headers)
            when :post  then    client.post(uri.request_uri, { :xml => body }, headers)
            when :put   then    client.put(uri.request_uri, { :xml => body }, headers)
          end

          if self.logger
            logger.info("== [#{Time.now.to_s}] XeroGateway Response (#{response.code})")

            unless response.code.to_i == 200
              logger.info("== #{uri.request_uri} Response Body \n\n #{response.plain_body} \n == End Response Body")
            end
          end

          case response.code.to_i
            when 200
              response.plain_body
            when 400
              handle_error!(response, body)
            when 401
              handle_oauth_error!(response)
            when 404
              handle_object_not_found!(response, url)
            when 503
              handle_oauth_error!(response)
            else
              raise "Unknown response code: #{response.code.to_i}"
          end
        rescue Xeroizer::OAuth::RateLimitExceeded
          if self.rate_limit_sleep
            raise if attempts > rate_limit_max_attempts
            logger.info("== Rate limit exceeded, retrying") if self.logger
            sleep_for(self.rate_limit_sleep)
            retry
          else
            raise
          end
        end
      end
       
      def handle_oauth_error!(response)
        error_details = CGI.parse(response.plain_body)
        description   = error_details["oauth_problem_advice"].first
      
        # see http://oauth.pbworks.com/ProblemReporting
        # In addition to token_expired and token_rejected, Xero also returns
        # 'rate limit exceeded' when more than 60 requests have been made in
        # a second.
        case (error_details["oauth_problem"].first)
          when "token_expired"        then raise OAuth::TokenExpired.new(description)
          when "token_rejected"       then raise OAuth::TokenInvalid.new(description)
          when "rate limit exceeded"  then raise OAuth::RateLimitExceeded.new(description)
          else raise OAuth::UnknownError.new(error_details["oauth_problem"].first + ':' + description)
        end
      end
      
      def handle_error!(response, request_body)
        
        raw_response = response.plain_body
        
        # XeroGenericApplication API Exceptions *claim* to be UTF-16 encoded, but fail REXML/Iconv parsing...
        # So let's ignore that :)
        raw_response.gsub! '<?xml version="1.0" encoding="utf-16"?>', ''
        
        # doc = REXML::Document.new(raw_response, :ignore_whitespace_nodes => :all)
        doc = Nokogiri::XML(raw_response)
        
        if doc && doc.root && doc.root.name == "ApiException"

          raise ApiException.new(doc.root.xpath("Type").text,
                                 doc.root.xpath("Message").text,
                                 raw_response,
                                 doc,
                                 request_body)

        else
          
          raise "Unparseable 400 Response: #{raw_response}"
          
        end
        
      end
      
      def handle_object_not_found!(response, request_url)
        case(request_url)
          when /Invoices/ then raise InvoiceNotFoundError.new("Invoice not found in Xero.")
          when /CreditNotes/ then raise CreditNoteNotFoundError.new("Credit Note not found in Xero.")
          else raise ObjectNotFound.new(request_url)
        end
      end

      def sleep_for(seconds = 1)
        sleep seconds
      end
      
  end
end
