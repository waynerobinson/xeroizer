require "base64"
require "io/wait"
require "json"
require "oauth2"
require "securerandom"
require "socket"
require "uri"
require_relative "xero_env"

# Keeps the tokens and tenant in XeroEnv.path usable: reuses the access token,
# else refreshes it, else logs in through the browser.
# XERO_TENANT_ID follows the connected org, since a Demo Company gets a new ID on reset.
module XeroToken
  DEFAULT_REDIRECT_URI = "http://localhost:8749/callback".freeze
  # Granular scopes: apps created since March 2026 cannot request accounting.transactions.
  SCOPES = %w[
    openid
    profile
    email
    offline_access
    accounting.invoices
    accounting.payments
    accounting.banktransactions
    accounting.settings
    accounting.contacts
    accounting.attachments
  ].join(" ").freeze
  CONNECTIONS_URL = "https://api.xero.com/connections".freeze
  MIN_SECONDS_LEFT = 300
  LOGIN_TIMEOUT = 600
  REQUEST_TIMEOUT = 5
  MAX_REQUEST_HEAD = 16_384
  TOKENS = %w[XERO_ACCESS_TOKEN XERO_REFRESH_TOKEN].freeze

  module_function

  def run(login: false)
    env = load_env
    check_setup(env)
    browser_login(env) if login || !reuse_or_refresh(env)
  end

  # Tokens come only from the file this task rotates; an exported copy may be stale or another app's.
  # ENV takes them too, so the tests run in the same command use them on every path.
  def load_env
    tokens = XeroEnv.file_values.slice(*TOKENS)
    ENV.update(tokens)
    XeroEnv.values.except(*TOKENS).merge(tokens)
  end

  def check_setup(env)
    missing = %w[XERO_CLIENT_ID XERO_CLIENT_SECRET].select { |k| env[k].to_s.empty? }
    abort "Set #{missing.join(' and ')} in #{XeroEnv.path} first." if missing.any?

    # A refresh token works only with the app that issued it.
    file_client_id = XeroEnv.file_values["XERO_CLIENT_ID"].to_s
    if !file_client_id.empty? && env["XERO_CLIENT_ID"] != file_client_id
      abort "XERO_CLIENT_ID in the environment differs from #{XeroEnv.path}. Unset it or set XERO_ENV_FILE."
    end

    # Checked before any grant, because a rotated refresh token that cannot be saved is lost.
    abort "Cannot write #{XeroEnv.path}." unless File.writable?(File.dirname(XeroEnv.write_path))
  end

  def client(env)
    OAuth2::Client.new(
      env["XERO_CLIENT_ID"],
      env["XERO_CLIENT_SECRET"],
      site: "https://api.xero.com",
      authorize_url: "https://login.xero.com/identity/connect/authorize",
      token_url: "https://identity.xero.com/connect/token",
      raise_errors: true
    )
  end

  # True when the file ends up usable without a browser login.
  def reuse_or_refresh(env)
    token = reused_or_refreshed_token(env)
    return false unless token

    connected = connections(token)
    tenant = pick_tenant(env, connected)
    unless tenant
      puts "XERO_TENANT_ID is not connected, and #{connected.size} orgs are."
      return false
    end
    use_tenant(env, tenant)
    true
  rescue OAuth2::Error => e
    puts "Rejected (#{reason(e)})."
    false
  end

  def reused_or_refreshed_token(env)
    left = seconds_left(env["XERO_ACCESS_TOKEN"])
    if left > MIN_SECONDS_LEFT
      puts "Access token is valid for #{left / 60} more minutes."
      return OAuth2::AccessToken.new(client(env), env["XERO_ACCESS_TOKEN"])
    end
    return if env["XERO_REFRESH_TOKEN"].to_s.empty?

    token = client(env).get_token(
      grant_type: "refresh_token",
      refresh_token: env["XERO_REFRESH_TOKEN"]
    )
    puts "Refreshed."
    save(token)
  end

  def browser_login(env)
    uri = redirect_uri(env)
    state = SecureRandom.urlsafe_base64(24)
    server = listen(URI(uri))

    url = client(env).auth_code.authorize_url(redirect_uri: uri, scope: SCOPES, state: state)
    puts "Opening your browser. Approve one org.\nIf nothing opens, use:\n#{url}"
    open_browser(url)
    code = wait_for_code(server, URI(uri).path, state)

    token = save(client(env).auth_code.get_token(code, redirect_uri: uri))
    connected = login_connections(token)
    tenant = pick_tenant(env, connected)
    unless tenant
      abort "Tokens saved, but cannot pick an org. Connected: #{describe(connected)}. Set XERO_TENANT_ID by hand."
    end
    use_tenant(env, tenant)
  rescue OAuth2::Error => e
    abort "Login rejected (#{reason(e)})."
  end

  # Must match a redirect URI registered on the Xero app.
  def redirect_uri(env)
    env["XERO_REDIRECT_URI"].to_s.empty? ? DEFAULT_REDIRECT_URI : env["XERO_REDIRECT_URI"]
  end

  def listen(callback)
    TCPServer.new("127.0.0.1", callback.port)
  rescue SystemCallError => e
    abort "Cannot listen on #{callback.host}:#{callback.port}: #{e.message}"
  end

  # macOS and Linux; elsewhere the printed URL is the way in.
  def open_browser(url)
    command = RbConfig::CONFIG["host_os"].include?("darwin") ? "open" : "xdg-open"
    Process.detach(spawn(command, url, %i[out err] => File::NULL))
  rescue SystemCallError
    nil
  end

  def wait_for_code(server, path, state)
    deadline = Time.now + LOGIN_TIMEOUT
    while Time.now < deadline
      next unless server.wait_readable(1)

      query = answer(server.accept, path, state)
      next unless query
      abort "Login failed: #{query['error']}." if query["error"]
      return query["code"]
    end
    abort "Timed out waiting for the browser login."
  ensure
    server.close
  end

  # Answers one request. Returns the callback's query, or nil to keep waiting.
  def answer(socket, path, state)
    target = read_request_target(socket)
    return unless target

    query = URI.decode_www_form(target.query.to_s).to_h
    if target.path != path
      reply(socket, "404 Not Found", "Not found.")
      return
    end
    if query["state"] != state
      reply(socket, "200 OK", "State mismatch; ignored. Use the link the task opened.")
      return
    end
    reply(socket, "200 OK", query["error"] ? "Xero returned: #{query['error']}" : "Done. You can close this tab.")
    query
  rescue SystemCallError, IOError, URI::InvalidURIError, ArgumentError
    nil
  ensure
    socket.close
  end

  # Returns the URI from the request line, after reading the whole request head
  # so the browser receives the reply. Returns nil if the head is not complete
  # within REQUEST_TIMEOUT seconds, such as on an idle connection a browser opens ahead of time.
  def read_request_target(socket)
    head = +""
    deadline = Time.now + REQUEST_TIMEOUT
    until head.match?(/\r?\n\r?\n/)
      left = deadline - Time.now
      return if left <= 0 || head.bytesize > MAX_REQUEST_HEAD || !socket.wait_readable(left)

      head << socket.readpartial(4096)
    end
    URI(head.lines.first.split[1].to_s)
  end

  def reply(socket, status, body)
    socket.write([
      "HTTP/1.1 #{status}",
      "Content-Type: text/plain; charset=utf-8",
      "Content-Length: #{body.bytesize}",
      "Connection: close",
      "",
      body
    ].join("\r\n"))
  end

  # Xero rotates the refresh token, so this runs straight after every grant.
  def save(token)
    if token.token.to_s.empty? || token.refresh_token.to_s.empty?
      abort "Xero returned no usable tokens; #{XeroEnv.path} left unchanged."
    end
    XeroEnv.write(
      "XERO_ACCESS_TOKEN" => token.token,
      "XERO_REFRESH_TOKEN" => token.refresh_token
    )
    puts "Saved new tokens to #{XeroEnv.path}."
    token
  end

  def connections(token, auth_event_id = nil)
    params = auth_event_id ? { authEventId: auth_event_id } : {}
    token.get(CONNECTIONS_URL, params: params).parsed
  end

  # The orgs this login connected, else all connected orgs:
  # the auth event lists only newly connected orgs, not a re-approved one.
  def login_connections(token)
    event_id = claims(token.token)["authentication_event_id"]
    connected = event_id ? connections(token, event_id) : []
    connected.empty? ? connections(token) : connected
  end

  def pick_tenant(env, connected)
    return connected.first if connected.size == 1

    connected.find { |c| c["tenantId"] == env["XERO_TENANT_ID"] }
  end

  def use_tenant(env, connection)
    if connection["tenantId"] == env["XERO_TENANT_ID"]
      puts "Connected to #{connection['tenantName']}."
    else
      XeroEnv.write("XERO_TENANT_ID" => connection["tenantId"])
      puts "Connected to #{connection['tenantName']}. XERO_TENANT_ID is now #{connection['tenantId']}."
    end
  end

  def describe(connected)
    return "none" if connected.empty?

    connected.map { |c| "#{c['tenantName']} (#{c['tenantId']})" }.join(", ")
  end

  def claims(token)
    JSON.parse(Base64.urlsafe_decode64(token.to_s.split(".")[1].to_s))
  rescue ArgumentError, JSON::ParserError
    {}
  end

  def seconds_left(token)
    claims(token).fetch("exp", 0).to_i - Time.now.to_i
  end

  def reason(error)
    text = [error.code, error.description].compact.join(": ")
    text.empty? ? "HTTP #{error.response&.status}" : text
  end
end
