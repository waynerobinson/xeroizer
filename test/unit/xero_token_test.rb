require 'unit_test_helper'
require 'tmpdir'
require 'timeout'
require_relative '../support/xero_token'

module XeroEnvSandbox
  def setup
    super
    @saved_env = ENV.to_h.select { |key, _| key.start_with?("XERO_") }
    @saved_env.each_key { |key| ENV.delete(key) }
    @dir = Dir.mktmpdir
    ENV["XERO_ENV_FILE"] = File.join(@dir, "xero.env")
  end

  def teardown
    ENV.keys.grep(/\AXERO_/).each { |key| ENV.delete(key) }
    ENV.update(@saved_env)
    FileUtils.remove_entry(@dir)
    super
  end

  def env_file
    ENV["XERO_ENV_FILE"]
  end
end

class XeroEnvTest < UnitTestCase
  include XeroEnvSandbox

  def test_write_replaces_and_appends_keys_and_keeps_other_lines
    File.write(env_file, <<~ENV_FILE)
      # note
      export XERO_ACCESS_TOKEN=old
      XERO_CLIENT_ID=id
      XERO_ACCESS_TOKEN=old
    ENV_FILE

    XeroEnv.write("XERO_ACCESS_TOKEN" => "new", "XERO_TENANT_ID" => "t1")

    assert_equal <<~ENV_FILE, File.read(env_file)
      # note
      export XERO_ACCESS_TOKEN=new
      XERO_CLIENT_ID=id
      XERO_ACCESS_TOKEN=new
      XERO_TENANT_ID=t1
    ENV_FILE
    assert_equal 0o600, File.stat(env_file).mode & 0o777
    assert_equal %w[xero.env], Dir.children(@dir)
    assert_equal "new", ENV["XERO_ACCESS_TOKEN"]
    assert_equal "t1", ENV["XERO_TENANT_ID"]
  end

  def test_write_through_a_symlink_updates_its_target
    real = File.join(@dir, "real.env")
    File.write(real, "XERO_ACCESS_TOKEN=old\n")
    File.symlink(real, env_file)

    XeroEnv.write("XERO_ACCESS_TOKEN" => "new")

    assert File.symlink?(env_file)
    assert_equal "XERO_ACCESS_TOKEN=new\n", File.read(real)
  end

  def test_write_creates_a_missing_file
    XeroEnv.write("XERO_TENANT_ID" => "t1")

    assert_equal "XERO_TENANT_ID=t1\n", File.read(env_file)
  end

  def test_values_prefer_non_empty_env_over_the_file
    File.write(env_file, <<~ENV_FILE)
      XERO_CLIENT_ID="from_file"
      XERO_TENANT_ID='t1'
    ENV_FILE
    ENV["XERO_CLIENT_ID"] = "from_env"
    ENV["XERO_TENANT_ID"] = ""

    values = XeroEnv.values.slice("XERO_CLIENT_ID", "XERO_TENANT_ID")

    assert_equal({ "XERO_CLIENT_ID" => "from_env", "XERO_TENANT_ID" => "t1" }, values)
  end
end

class XeroTokenTest < UnitTestCase
  include XeroEnvSandbox

  TOKEN_URL = "https://identity.xero.com/connect/token".freeze

  def setup
    super
    @fresh = jwt(Time.now.to_i + 1800)
    File.write(env_file, <<~ENV_FILE)
      XERO_CLIENT_ID=dummy_id
      XERO_CLIENT_SECRET=dummy_secret
      XERO_ACCESS_TOKEN=#{@fresh}
      XERO_REFRESH_TOKEN=dummy_refresh_token_from_file
      XERO_TENANT_ID=t1
    ENV_FILE
  end

  def test_claims_of_a_malformed_token_are_empty
    assert_equal({}, XeroToken.claims("not-a-jwt"))
    assert_equal({}, XeroToken.claims("h.!!!.s"))
  end

  def test_seconds_left_reads_the_exp_claim
    assert_in_delta 1800, XeroToken.seconds_left(@fresh), 5
    assert_operator XeroToken.seconds_left("not-a-jwt"), :<, 0
  end

  # Regression guard: the reuse path must hand the file's token, not a stale exported one, to child processes.
  def test_reuse_puts_the_file_tokens_in_env_over_stale_exported_ones
    ENV["XERO_CLIENT_ID"] = "dummy_id"
    ENV["XERO_ACCESS_TOKEN"] = "stale_exported"
    ENV["XERO_REFRESH_TOKEN"] = "stale_exported_refresh"
    stub_connections("t1")
    XeroToken.expects(:browser_login).never

    capture_io { XeroToken.run }

    assert_equal @fresh, ENV["XERO_ACCESS_TOKEN"]
    assert_equal "dummy_refresh_token_from_file", ENV["XERO_REFRESH_TOKEN"]
    assert_requested :get, XeroToken::CONNECTIONS_URL, headers: { "Authorization" => "Bearer #{@fresh}" }
  end

  def test_refresh_saves_the_rotated_tokens
    expire_access_token
    new_access = jwt(Time.now.to_i + 1800)
    stub_request(:post, TOKEN_URL).to_return(
      headers: { "Content-Type" => "application/json" },
      body: JSON.generate(
        access_token: new_access,
        refresh_token: "dummy_rotated_refresh_token",
        token_type: "Bearer",
        expires_in: 1800
      )
    )
    stub_connections("t1")
    XeroToken.expects(:browser_login).never

    output = capture_io { XeroToken.run }.join

    assert_equal new_access, XeroEnv.file_values["XERO_ACCESS_TOKEN"]
    assert_equal "dummy_rotated_refresh_token", XeroEnv.file_values["XERO_REFRESH_TOKEN"]
    assert_equal "dummy_rotated_refresh_token", ENV["XERO_REFRESH_TOKEN"]
    refute_prints_saved_tokens output
  end

  def test_refresh_without_a_new_refresh_token_leaves_the_file_unchanged
    expire_access_token
    before = File.read(env_file)
    stub_request(:post, TOKEN_URL).to_return(
      headers: { "Content-Type" => "application/json" },
      body: JSON.generate(
        access_token: jwt(Time.now.to_i + 1800),
        token_type: "Bearer",
        expires_in: 1800
      )
    )

    _, err = capture_io { assert_raises(SystemExit) { XeroToken.run } }

    assert_includes err, "Xero returned no usable tokens"
    assert_equal before, File.read(env_file)
  end

  def test_rejected_refresh_falls_back_to_browser_login
    expire_access_token
    stub_request(:post, TOKEN_URL).to_return(
      status: 400,
      headers: { "Content-Type" => "application/json" },
      body: '{"error":"invalid_grant"}'
    )
    XeroToken.expects(:browser_login).once

    out, = capture_io { XeroToken.run }

    assert_includes out, "Rejected (invalid_grant)."
    assert_equal "dummy_refresh_token_from_file", XeroEnv.file_values["XERO_REFRESH_TOKEN"]
  end

  # Regression guard: the file's tokens must not be sent with another app's exported client.
  def test_aborts_when_the_env_client_id_differs_from_the_file
    expire_access_token
    ENV["XERO_CLIENT_ID"] = "other_app_id"
    XeroToken.expects(:browser_login).never

    _, err = capture_io { assert_raises(SystemExit) { XeroToken.run } }

    assert_includes err, "XERO_CLIENT_ID in the environment differs"
    assert_not_requested :post, TOKEN_URL
    assert_equal "dummy_refresh_token_from_file", XeroEnv.file_values["XERO_REFRESH_TOKEN"]
  end

  # Regression guard: a rotated refresh token that cannot be saved is lost.
  def test_aborts_before_any_grant_when_the_env_file_is_not_writable
    expire_access_token
    File.stubs(:writable?).returns(false)
    XeroToken.expects(:browser_login).never

    _, err = capture_io { assert_raises(SystemExit) { XeroToken.run } }

    assert_includes err, "Cannot write #{env_file}."
    assert_not_requested :post, TOKEN_URL
  end

  # Regression guard: exported tokens belong to another store, so they are never reused or rotated here.
  def test_without_tokens_in_the_file_logs_in_instead_of_using_exported_ones
    File.write(env_file, <<~ENV_FILE)
      XERO_CLIENT_ID=dummy_id
      XERO_CLIENT_SECRET=dummy_secret
    ENV_FILE
    ENV["XERO_ACCESS_TOKEN"] = jwt(Time.now.to_i + 1800)
    ENV["XERO_REFRESH_TOKEN"] = "dummy_exported_refresh_token"
    XeroToken.expects(:browser_login).once

    capture_io { XeroToken.run }

    assert_not_requested :post, TOKEN_URL
    assert_not_requested :get, XeroToken::CONNECTIONS_URL
  end

  def test_stored_tenant_missing_among_several_orgs_falls_back_to_browser_login
    stub_connections("t2", "t3")
    XeroToken.expects(:browser_login).once

    capture_io { XeroToken.run }

    assert_equal "t1", XeroEnv.file_values["XERO_TENANT_ID"]
  end

  def test_single_connected_org_replaces_the_stored_tenant
    stub_connections("t2")
    XeroToken.expects(:browser_login).never

    capture_io { XeroToken.run }

    assert_equal "t2", XeroEnv.file_values["XERO_TENANT_ID"]
    assert_equal "t2", ENV["XERO_TENANT_ID"]
  end

  def test_redirect_uri_comes_from_env_or_file_else_the_default
    assert_equal XeroToken::DEFAULT_REDIRECT_URI, XeroToken.redirect_uri(XeroEnv.values)

    XeroEnv.write("XERO_REDIRECT_URI" => "http://localhost:9999/cb")
    ENV.delete("XERO_REDIRECT_URI")

    assert_equal "http://localhost:9999/cb", XeroToken.redirect_uri(XeroEnv.values)
  end

  def test_login_falls_back_to_all_connections_and_keeps_the_stored_tenant
    stub_login(event_orgs: [], all_orgs: %w[t1 t2])

    output = capture_io { XeroToken.browser_login(XeroEnv.values) }.join

    assert_equal "t1", XeroEnv.file_values["XERO_TENANT_ID"]
    assert_equal "dummy_login_refresh_token", XeroEnv.file_values["XERO_REFRESH_TOKEN"]
    refute_prints_saved_tokens output
  end

  def test_login_picks_the_single_newly_connected_org
    stub_login(event_orgs: %w[t2], all_orgs: %w[t1 t2])

    capture_io { XeroToken.browser_login(XeroEnv.values) }

    assert_equal "t2", XeroEnv.file_values["XERO_TENANT_ID"]
  end

  def test_login_aborts_when_it_cannot_pick_an_org
    stub_login(event_orgs: [], all_orgs: %w[t2 t3])

    _, err = capture_io { assert_raises(SystemExit) { XeroToken.browser_login(XeroEnv.values) } }

    assert_includes err, "cannot pick an org. Connected: Org t2 (t2), Org t3 (t3)."
    assert_equal "dummy_login_refresh_token", XeroEnv.file_values["XERO_REFRESH_TOKEN"]
  end

  def test_answer_returns_the_query_only_for_the_callback_with_the_expected_state
    assert_equal({ "code" => "c1", "state" => "s1" }, answer("GET /callback?code=c1&state=s1 HTTP/1.1"))
    assert_nil answer("GET /callback?code=c1&state=forged HTTP/1.1")
    assert_nil answer("GET /other?code=c1&state=s1 HTTP/1.1")
    assert_equal "access_denied", answer("GET /callback?error=access_denied&state=s1 HTTP/1.1")["error"]
  end

  def test_answer_gives_up_on_an_idle_connection
    browser, server_side = UNIXSocket.pair
    server_side.stubs(:wait_readable).returns(nil)

    assert_nil XeroToken.answer(server_side, "/callback", "s1")
    assert server_side.closed?
  ensure
    browser.close
  end

  # Regression guard: a client that never ends its request line must not hold the callback past the deadline.
  def test_answer_gives_up_on_a_request_line_that_never_ends
    browser, server_side = UNIXSocket.pair
    browser.write("\x16\x03\x01")
    server_side.stubs(:wait_readable).returns(server_side, nil)

    Timeout.timeout(2) { assert_nil XeroToken.answer(server_side, "/callback", "s1") }
    assert server_side.closed?
  ensure
    browser.close
  end

  def test_login_task_logs_in_even_with_a_valid_access_token
    XeroToken.expects(:reuse_or_refresh).never
    XeroToken.expects(:browser_login).once

    XeroToken.run(login: true)
  end

  def test_claims_read_an_unpadded_payload
    payload = Base64.urlsafe_encode64(JSON.generate("exp" => 12), padding: false)

    refute payload.end_with?("=")
    assert_equal({ "exp" => 12 }, XeroToken.claims("h.#{payload}.s"))
  end

  private

  def answer(request_line)
    browser, server_side = UNIXSocket.pair
    browser.write("#{request_line}\r\nHost: localhost\r\n\r\n")
    XeroToken.answer(server_side, "/callback", "s1")
  ensure
    browser.close
  end

  # Unsigned: XeroToken reads the claims but never verifies them.
  def jwt(exp, **claims)
    payload = Base64.urlsafe_encode64(JSON.generate("exp" => exp, **claims), padding: false)
    "h.#{payload}.s"
  end

  # A browser login on a free port that returns a token for auth event e1.
  # It accepts only the callback state from the authorize URL and a code exchange with the same redirect_uri.
  def stub_login(event_orgs:, all_orgs:)
    redirect_uri = "http://localhost:0/callback"
    sent = {}
    XeroEnv.write("XERO_REDIRECT_URI" => redirect_uri)
    XeroToken.stubs(:open_browser).with { |url| sent.update(URI.decode_www_form(URI(url).query).to_h) }
    XeroToken.stubs(:wait_for_code)
      .with { |_server, path, state| path == "/callback" && state == sent["state"] }
      .returns("dummy_code")
    stub_request(:post, TOKEN_URL)
      .with(
        body: hash_including(
          "grant_type" => "authorization_code",
          "code" => "dummy_code",
          "redirect_uri" => redirect_uri
        )
      )
      .to_return(
        headers: { "Content-Type" => "application/json" },
        body: JSON.generate(
          access_token: jwt(Time.now.to_i + 1800, authentication_event_id: "e1"),
          refresh_token: "dummy_login_refresh_token",
          token_type: "Bearer",
          expires_in: 1800
        )
      )
    stub_connections(*all_orgs)
    stub_connections(*event_orgs, query: { authEventId: "e1" })
  end

  def refute_prints_saved_tokens(output)
    XeroEnv.file_values.values_at(*XeroToken::TOKENS).each { |token| refute_includes output, token }
  end

  def expire_access_token
    XeroEnv.write("XERO_ACCESS_TOKEN" => jwt(Time.now.to_i - 60))
  end

  def stub_connections(*tenant_ids, query: {})
    orgs = tenant_ids.map { |id| { tenantId: id, tenantName: "Org #{id}" } }
    stub_request(:get, XeroToken::CONNECTIONS_URL)
      .with(query: query)
      .to_return(
        headers: { "Content-Type" => "application/json" },
        body: JSON.generate(orgs)
      )
  end
end
