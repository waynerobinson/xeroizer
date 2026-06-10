# frozen_string_literal: true

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
    class BadResponse < XeroizerError; end
    RequestInfo = Struct.new(:url, :headers, :params, :body, :method)

    ACCEPT_MIME_MAP = {
      pdf: 'application/pdf',
      json: 'application/json'
    }.freeze

    # Shortcut method for #http_request with `method` = :get.
    #
    # @param [OAuth2] client OAuth2 client
    # @param [String] url URL of request
    # @param [Hash] extra_params extra query string parameters.
    def http_get(client, url, extra_params = {})
      http_request(client, :get, url, nil, extra_params)
    end

    # Shortcut method for #http_request with `method` = :post.
    #
    # @param [OAuth2] client OAuth2 client
    # @param [String] url URL of request
    # @param [String] body XML message to post.
    # @param [Hash] extra_params extra query string parameters.
    def http_post(client, url, body, extra_params = {})
      http_request(client, :post, url, body, extra_params)
    end

    # Shortcut method for #http_request with `method` = :put.
    #
    # @param [OAuth2] client OAuth2 client
    # @param [String] url URL of request
    # @param [String] body XML message to put.
    # @param [Hash] extra_params extra query string parameters.
    def http_put(client, url, body, extra_params = {})
      http_request(client, :put, url, body, extra_params)
    end

    private

    def http_request(client, method, url, request_body, params = {})
      # headers = {'Accept-Encoding' => 'gzip, deflate'}

      headers = default_headers.merge({ 'charset' => 'utf-8' })

      # include the unitdp query string parameter
      params.merge!(unitdp_param(url))

      headers['Content-Type'] ||= 'application/x-www-form-urlencoded' if method != :get

      content_type = params.delete(:content_type)
      headers['Content-Type'] = content_type if content_type

      # HAX.  Xero completely misuse the If-Modified-Since HTTP header.
      if params[:ModifiedAfter]
        headers['If-Modified-Since'] =
          params.delete(:ModifiedAfter).utc.strftime('%Y-%m-%dT%H:%M:%S')
      end

      # Allow 'Accept' header to be specified with :accept parameter.
      # Valid values are :pdf or :json.
      if params[:response]
        response_type = params.delete(:response)
        headers['Accept'] = case response_type
                            when Symbol then ACCEPT_MIME_MAP[response_type]
                            else response_type
                            end
      end

      # Compute the request body once, before the retry loop, so retries
      # send the same body on every attempt. Also done before URL building
      # so :raw_body isn't serialized into the query string.
      raw_body = params.delete(:raw_body) ? request_body : { xml: request_body }

      if params.any?
        url += '?' + params.map { |key, value| "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}" }.join('&')
      end

      uri = URI.parse(url)

      attempts = 0

      request_info = RequestInfo.new(url, headers, params, request_body, method)
      before_request.call(request_info) if before_request

      begin
        attempts += 1
        logger.info("XeroGateway Request: #{method.to_s.upcase} #{uri.request_uri}") if logger

        response = with_around_request(request_info) do
          case method
          when :get   then    client.get(uri.request_uri, headers)
          when :post  then    client.post(uri.request_uri, raw_body, headers)
          when :put   then    client.put(uri.request_uri, raw_body, headers)
          end
        end

        log_response(response, uri)
        after_request.call(request_info, response) if after_request

        HttpResponse.from_response(response, request_body, url).body
      rescue Xeroizer::OAuth::RateLimitExceeded => e
        sleep_duration = rate_limit_sleep_duration!(e, attempts)
        if logger
          logger.warn(
            "Rate limit exceeded (attempt #{attempts}/#{rate_limit_max_attempts}, " \
            "retry_after=#{e.retry_after}s, " \
            "daily_remaining=#{e.daily_limit_remaining}); " \
            "sleeping #{sleep_duration}s before retry"
          )
        end
        sleep_for(sleep_duration)
        retry
      rescue ::OAuth2::Error => e
        # When raise_errors: true is set on the OAuth2 client, the oauth2 gem
        # raises OAuth2::Error for any non-2xx response before xeroizer's
        # HttpResponse layer can inspect it. This means 429 responses never
        # reach the normal RateLimitExceeded path above.
        #
        # This rescue intercepts those raw OAuth2::Error exceptions, converts
        # 429s to RateLimitExceeded, and feeds them through the same retry
        # logic so rate_limit_sleep works regardless of raise_errors setting.
        raise unless e.response && e.response.status == 429

        # Run the same observability hooks the raise_errors:false path runs,
        # so log_response/after_request fire for both modes symmetrically.
        wrapped_response = Xeroizer::OAuth2::Response.new(e.response)
        log_response(wrapped_response, uri)
        after_request.call(request_info, wrapped_response) if after_request

        rate_limit_exception = Xeroizer::OAuth::RateLimitExceeded.from_headers(e.response.headers)
        sleep_duration = rate_limit_sleep_duration!(rate_limit_exception, attempts)
        if logger
          logger.warn(
            'Rate limit exceeded (intercepted OAuth2::Error, ' \
            "attempt #{attempts}/#{rate_limit_max_attempts}, " \
            "retry_after=#{rate_limit_exception.retry_after}s, " \
            "daily_remaining=#{rate_limit_exception.daily_limit_remaining}); " \
            "sleeping #{sleep_duration}s before retry"
          )
        end
        sleep_for(sleep_duration)
        retry
      end
    end

    def with_around_request(request, &block)
      if around_request
        around_request.call(request, &block)
      else
        block.call
      end
    end

    def log_response(response, uri)
      return unless logger

      logger.info("XeroGateway Response (#{response.code})")
      logger.add(response.code.to_i == 200 ? Logger::DEBUG : Logger::INFO) do
        "#{uri.request_uri}\n== Response Body\n\n#{response.plain_body}\n== End Response Body"
      end
    end

    def sleep_for(seconds = 1)
      sleep seconds
    end

    def rate_limit_sleep_duration!(exception, attempts)
      raise exception unless rate_limit_sleep
      raise exception if attempts > rate_limit_max_attempts

      if rate_limit_sleep == true
        exception.retry_after && exception.retry_after > 0 ? exception.retry_after : 1
      else
        [rate_limit_sleep.to_f, 0].max
      end
    end

    # unitdp query string parameter to be added to request params
    # when the application option has been set and the model has line items
    # https://developer.xero.com/documentation/api-guides/rounding-in-xero#unitamount
    def unitdp_param(request_url)
      models = [/Invoices/, /CreditNotes/, /BankTransactions/, /Receipts/, /Items/, /Overpayments/, /Prepayments/]
      unitdp == 4 && models.any? { |m| request_url =~ m } ? { unitdp: 4 } : {}
    end
  end
end
