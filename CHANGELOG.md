# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

> These changes have been merged but not yet released, so the version they will
> ship in is not yet decided. Note that this section contains a **breaking
> change** (see below); under SemVer that implies the next release will be a new
> major version.

### Breaking

- 429 responses now raise `Xeroizer::OAuth::RateLimitExceeded` instead of the
  raw `OAuth2::Error` for consumers running the OAuth2 client with
  `raise_errors: true`. Update any rescue chains accordingly.
  Non-429 `OAuth2::Error`s are unaffected and still propagate unchanged.
- The `nonce_used_max_attempts` option and its reader were removed;
  `app.nonce_used_max_attempts` now raises `NoMethodError`.

### Added

- `company_number` attribute on Contact. (#559)
- `edition` attribute on Organisation. (#564)
- `batch_payment_id` attribute on Payment. (#568)

### Changed

- `oauth2` now requires `>= 2.0", "< 3.0`; the client uses oauth2 2.x request
  and error semantics. The previous `>= 1.4.0` floor allowed 1.x, which would
  mis-send request bodies.
- `LineItem#line_item_id` is now a guid, producing `LineItemID` in XML to match Xero's case-sensitive parsing. (#562)
- `rate_limit_sleep: true` now respects the `Retry-After` response header. (#569)
- New `rate_limit_max_sleep` option (default 120) caps the `Retry-After` honored
  by `rate_limit_sleep: true`; a larger value (daily limit exhausted) raises
  `Xeroizer::OAuth::RateLimitExceeded` instead of sleeping. Pass `false` to
  sleep uncapped. A fixed numeric `rate_limit_sleep` is never capped.
- `rate_limit_sleep` now also works under `raise_errors: true`.
- A numeric `rate_limit_sleep` is now clamped to a non-negative number.
  Fractional values are preserved (`2.5` sleeps 2.5 seconds). Negative values
  sleep 0 seconds rather than raising.
- Under `raise_errors: true`, the `before_request`/`after_request` and response
  logging hooks now fire for 429 responses (they previously could not, because
  the `oauth2` gem raised before xeroizer's response layer ran). This keeps
  observability consistent across both `raise_errors` modes.
- `activesupport` now requires `>= 7.0` (previously unconstrained, which let it
  resolve to ancient, EOL releases that fail to load on modern Ruby).
- Minimum supported Ruby is now 3.1 (`required_ruby_version >= 3.1`); RubyGems
  refuses to install the gem on older Rubies.

### Removed

- The dead `Net::HTTPResponse#plain_body` monkeypatch (`http_encoding_helper.rb`);
  responses use the `Xeroizer::OAuth2::Response` wrapper's `plain_body`.
- OAuth 1.0a transport support (#574). The `oauth` gem is no longer a dependency,
  and `Xeroizer::OAuthConfig` / `Xeroizer::OAuthCredentials` and the OAuth1 methods
  on `Xeroizer::OAuth` are gone. OAuth 2.0 is unaffected.
- The OAuth 1.0a-only error classes `Xeroizer::OAuth::ConsumerKeyUnknown` and
  `Xeroizer::OAuth::NonceUsed`, their error mappings, the nonce-reuse retry, and the
  `nonce_used_max_attempts` option that configured it.

### Fixed

- OAuth error response (401/403/503) parsing on Ruby 4.0, where `CGI.parse` was removed.
- Models without `set_permissions` now raise `MethodNotAllowed` on read instead
  of `NoMethodError` (e.g. `Schedule`).
- `:datetime` fields serialize `nil` as an empty element and raise a clear
  `ArgumentError` for non-time values, matching `:date`.
- The gem now requires `active_support/core_ext/object/blank` and `.../object/try`
  explicitly; it used `blank?`/`present?`/`try` but only loaded them transitively,
  which broke on modern ActiveSupport outside Rails.
- Loads ActiveSupport's deprecation framework before its core extensions,
  preventing a load-time crash on ActiveSupport versions that emit a deprecation
  from a cherry-picked file (e.g. 8.2).
- `#attributes=` now raises the same clear `undefined method` error as `.build` when given an invalid attribute name. (#570)
- Avoid an extra API call when accessing allocations from a credit note. (#554)
- A `raw_body: true` request body is now computed once before the retry loop, so
  a retried request re-sends the same raw body instead of falling back to the
  `xml=`-wrapped form, and `:raw_body` is no longer serialized into the request
  query string.
- `BrandingTheme#add_payment_service` now builds its request body with `Builder`
  instead of ActiveSupport's `Hash#to_xml`, removing a hidden dependency on an
  ActiveSupport extension the gem never required.
- `lib/xeroizer` now requires `json` explicitly rather than relying on it being
  loaded transitively by another gem.
- `lib/xeroizer` requires `cgi/escape` instead of the full `cgi` library (removed
  in Ruby 4.0) for the `CGI.escape` calls it makes.

## 3.0.1

See the Git history for changes up to and including 3.0.1.
