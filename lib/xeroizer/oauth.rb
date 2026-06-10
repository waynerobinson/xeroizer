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
  # Holds only error classes now (the OAuth 1.0a transport was removed). Keep
  # them here: callers rescue Xeroizer::OAuth::* and the OAuth 2.0 path raises them.
  class OAuth
    class OAuthError < XeroizerError; end
    class TokenExpired < OAuthError; end
    class TokenInvalid < OAuthError; end
    class OrganisationOffline < OAuthError; end
    class Forbidden < OAuthError; end
    class UnknownError < OAuthError; end

    class RateLimitExceeded < OAuthError
      # @api private
      def self.from_headers(headers)
        retry_after = (headers['retry-after'] || 0).to_i
        daily_limit_remaining = (headers['x-daylimit-remaining'] || 0).to_i
        description = "Rate limit exceeded: #{daily_limit_remaining} requests left for the day, #{retry_after} seconds until you can make another request"
        new(description, retry_after: retry_after, daily_limit_remaining: daily_limit_remaining)
      end

      def initialize(description, retry_after: nil, daily_limit_remaining: nil)
        super(description)

        @retry_after = retry_after
        @daily_limit_remaining = daily_limit_remaining
      end

      attr_reader :retry_after, :daily_limit_remaining
    end
  end
end
