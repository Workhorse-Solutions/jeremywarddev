# Rack::Attack — Auth endpoint rate limiting
#
# Backing store: Rails.cache (Solid Cache, already configured).
# Thresholds and periods are read from ENV vars with hardcoded fallback
# defaults. See .env.example for the full list of available overrides.
#
# Production note: configure config.action_dispatch.trusted_proxies so that
# req.ip resolves the real client IP behind a load balancer.
#
# Endpoints protected:
#   POST /login                      — credential brute-force & stuffing
#   POST /forgot-password            — password-reset abuse & email spam
#   POST /resend-verification        — email-verification resend spam
#   POST /email-verification/resend  — alternate resend path

# ---------------------------------------------------------------------------
# Safelists — never throttle these
# ---------------------------------------------------------------------------

# Health check endpoint used by uptime monitors and load balancers
Rack::Attack.safelist("allow health check") do |req|
  req.path == "/up"
end

# Loopback / localhost — never throttle internal requests
Rack::Attack.safelist("allow localhost") do |req|
  req.ip == "127.0.0.1" || req.ip == "::1"
end

# ---------------------------------------------------------------------------
# Blocklist examples (commented out — uncomment and adapt as needed)
# ---------------------------------------------------------------------------
#
# Block a single IP:
#   Rack::Attack.blocklist("block bad actor") do |req|
#     req.ip == "1.2.3.4"
#   end
#
# Block a CIDR range using the 'ipaddr' stdlib:
#   require "ipaddr"
#   BLOCKED_SUBNET = IPAddr.new("192.168.100.0/24")
#   Rack::Attack.blocklist("block subnet") do |req|
#     BLOCKED_SUBNET.include?(req.ip)
#   rescue IPAddr::InvalidAddressError
#     false
#   end
#
# Dynamic blocklist from Rails.cache (populate from an admin action):
#   Rack::Attack.blocklist("block dynamic IPs") do |req|
#     Rails.cache.read("blocked_ip:#{req.ip}")
#   end

# ---------------------------------------------------------------------------
# Login — per IP (burst protection)
# ---------------------------------------------------------------------------
Rack::Attack.throttle(
  "login/ip",
  limit:  ENV.fetch("RACK_ATTACK_LOGIN_LIMIT", 5).to_i,
  period: ENV.fetch("RACK_ATTACK_LOGIN_PERIOD", 20).to_i
) do |req|
  req.ip if req.path == "/login" && req.post?
end

# ---------------------------------------------------------------------------
# Login — per email (distributed credential stuffing across IPs)
# ---------------------------------------------------------------------------
Rack::Attack.throttle(
  "login/email",
  limit:  ENV.fetch("RACK_ATTACK_LOGIN_EMAIL_LIMIT", 10).to_i,
  period: ENV.fetch("RACK_ATTACK_LOGIN_EMAIL_PERIOD", 15.minutes.to_i).to_i
) do |req|
  if req.path == "/login" && req.post?
    req.params.dig("session", "email")&.downcase&.strip ||
      req.params.dig("email")&.downcase&.strip
  end
end

# ---------------------------------------------------------------------------
# Password reset — per IP
# ---------------------------------------------------------------------------
Rack::Attack.throttle(
  "forgot-password/ip",
  limit:  ENV.fetch("RACK_ATTACK_FORGOT_PASSWORD_LIMIT", 3).to_i,
  period: ENV.fetch("RACK_ATTACK_FORGOT_PASSWORD_PERIOD", 1.minute.to_i).to_i
) do |req|
  req.ip if req.path == "/forgot-password" && req.post?
end

# ---------------------------------------------------------------------------
# Password reset — per email (prevent email flooding across IPs)
# ---------------------------------------------------------------------------
Rack::Attack.throttle(
  "forgot-password/email",
  limit:  ENV.fetch("RACK_ATTACK_FORGOT_PASSWORD_EMAIL_LIMIT", 5).to_i,
  period: ENV.fetch("RACK_ATTACK_FORGOT_PASSWORD_EMAIL_PERIOD", 1.hour.to_i).to_i
) do |req|
  if req.path == "/forgot-password" && req.post?
    req.params.dig("email")&.downcase&.strip
  end
end

# ---------------------------------------------------------------------------
# Email verification resend — per IP (both route variants)
# ---------------------------------------------------------------------------
RESEND_VERIFICATION_PATHS = [ "/resend-verification", "/email-verification/resend" ].freeze

Rack::Attack.throttle(
  "resend-verification/ip",
  limit:  ENV.fetch("RACK_ATTACK_RESEND_VERIFICATION_LIMIT", 3).to_i,
  period: ENV.fetch("RACK_ATTACK_RESEND_VERIFICATION_PERIOD", 1.minute.to_i).to_i
) do |req|
  req.ip if RESEND_VERIFICATION_PATHS.include?(req.path) && req.post?
end

# ---------------------------------------------------------------------------
# Throttle response — HTTP 429 with Retry-After header
# ---------------------------------------------------------------------------
# Browser requests (Accept: text/html) receive a static HTML page.
# All other requests receive a JSON body.
#
# The Retry-After header value is sourced from the match data written by
# Rack::Attack into the request env.

Rack::Attack.throttled_responder = lambda do |request|
  env = request.env
  match_data = env["rack.attack.match_data"] || {}
  retry_after = if match_data[:period] && match_data[:count] && match_data[:limit]
    (match_data[:period] - (match_data[:count] % match_data[:period])).to_i
  else
    60
  end

  throttle_name = env["rack.attack.matched"] || "unknown"
  discriminator  = env["rack.attack.match_discriminator"] || "-"
  path           = env["PATH_INFO"] || "-"

  Rails.logger.warn(
    "[Rack::Attack] throttled name=#{throttle_name} discriminator=#{discriminator} path=#{path}"
  )

  headers = {
    "Content-Type" => "text/plain",
    "Retry-After"  => retry_after.to_s
  }

  accept = env["HTTP_ACCEPT"].to_s
  if accept.include?("text/html")
    html_body = Rails.public_path.join("429.html").read
    [ 429, headers.merge("Content-Type" => "text/html; charset=utf-8"), [ html_body ] ]
  else
    body = { error: "Too many requests. Please try again later.", retry_after: retry_after }.to_json
    [ 429, headers.merge("Content-Type" => "application/json; charset=utf-8"), [ body ] ]
  end
end
