module Xeroizer
  module Http
        
    def http_get(client, url, extra_params = {})
      http_request(client, :get, url, nil, extra_params)
    end

    def http_post(client, url, body, extra_params = {})
      http_request(client, :post, url, body, extra_params)
    end

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

        if params.any?
          url += "?" + params.map {|key,value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"}.join("&")
        end

        uri   = URI.parse(url)
        
        logger.info("\n== [#{Time.now.to_s}] XeroGateway Request: #{uri.request_uri} ") if self.logger
        
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
            handle_error!(response)  
          when 401
            handle_oauth_error!(response)
          when 404
            handle_object_not_found!(response, url)
          else
            raise "Unknown response code: #{response.code.to_i}"
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
      
      def handle_error!(response)
        
        raw_response = response.plain_body
        
        # Xero Gateway API Exceptions *claim* to be UTF-16 encoded, but fail REXML/Iconv parsing...
        # So let's ignore that :)
        raw_response.gsub! '<?xml version="1.0" encoding="utf-16"?>', ''
        
        doc = REXML::Document.new(raw_response, :ignore_whitespace_nodes => :all)
        
        if doc.root.name == "ApiException"

          raise ApiException.new(doc.root.elements["Type"].text, 
                                 doc.root.elements["Message"].text, 
                                 raw_response)

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
      
  end
end
