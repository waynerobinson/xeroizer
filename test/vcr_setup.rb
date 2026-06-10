require "vcr"

# Record mode is driven by VCR_MODE so CI replays and refreshes are explicit:
#   (unset) -> :none  replay only; an unmatched request fails the test
#   record  -> :once  record cassettes that don't exist yet; never touch existing ones
#   all     -> :all   re-record everything live
VCR_RECORD_MODE = case ENV["VCR_MODE"]
                  when "all"           then :all
                  when "record", "new" then :once
                  else                      :none
                  end

# Recording hits live Xero; fail fast instead of recording 401s with a fake token.
if VCR_RECORD_MODE != :none
  missing = %w[XERO_CLIENT_ID XERO_CLIENT_SECRET XERO_ACCESS_TOKEN XERO_TENANT_ID]
              .select { |k| ENV[k].to_s.empty? }
  abort "VCR_MODE=#{ENV['VCR_MODE']} records live; set #{missing.join(', ')} first." unless missing.empty?
end

VCR.configure do |c|
  c.cassette_library_dir = File.expand_path("fixtures/vcr_cassettes", __dir__)
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options = {
    record: VCR_RECORD_MODE,
    # Auth lives in headers and the token-endpoint body, neither of which we match
    # on, so a rotated/fake token still replays.
    match_requests_on: [:method, :uri],
    decode_compressed_response: true
  }

  # Scrub the configured credentials wherever their literal value appears.
  # Matching never depends on these, so unsubstituted placeholders on replay
  # are harmless.
  c.filter_sensitive_data("<XERO_CLIENT_ID>")     { ENV["XERO_CLIENT_ID"] }
  c.filter_sensitive_data("<XERO_CLIENT_SECRET>") { ENV["XERO_CLIENT_SECRET"] }
  c.filter_sensitive_data("<XERO_TENANT_ID>")     { ENV["XERO_TENANT_ID"] }
  c.filter_sensitive_data("<XERO_ACCESS_TOKEN>")  { ENV["XERO_ACCESS_TOKEN"] }

  # Redact secrets the value filters above can't see: the Authorization header
  # (Bearer on API calls, Basic on the token endpoint), the rotating tokens the
  # token endpoint echoes, and the org identity (every org the token can reach)
  # in the connections list.
  c.before_record do |interaction|
    request = interaction.request
    request.headers["Authorization"] &&= ["<REDACTED>"]

    next unless (body = interaction.response.body)
    if request.uri.include?("/connect/token")
      body = body.gsub(/"(access_token|refresh_token|id_token)"\s*:\s*"[^"]*"/, '"\1":"<REDACTED>"')
    end
    if request.uri.include?("/connections")
      body = body.gsub(/"(tenantId|id|tenantName)"\s*:\s*"[^"]*"/, '"\1":"<REDACTED>"')
    end
    # The online-invoice URL is a live public link to that specific invoice.
    body = body.gsub(%r{https://in\.xero\.com/[A-Za-z0-9]+}, "https://in.xero.com/<ONLINE_INVOICE_TOKEN>")
    interaction.response.body = body
  end
end
