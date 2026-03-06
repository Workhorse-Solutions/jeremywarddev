require "test_helper"

# Integration tests for Rack::Attack throttle rules.
#
# Each test uses an isolated ActiveSupport::Cache::MemoryStore so that
# throttle counters are independent of the null_store used by the rest of
# the test suite. The store is replaced in setup and torn down in teardown.
#
# Requests use a non-loopback REMOTE_ADDR so they are not exempted by the
# localhost safelist (loopback IPs are safelisted in the initializer to allow
# internal health-check and monitoring traffic to bypass throttles).
class RackAttackTest < ActionDispatch::IntegrationTest
  # Run sequentially — parallel workers share no state, but these tests
  # manipulate Rack::Attack global config so isolation is cleaner in-process.
  parallelize(workers: 1)

  EXTERNAL_IP = "203.0.113.42" # TEST-NET-3 (RFC 5737) — safe for test use

  setup do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rack::Attack.cache.store = ActiveSupport::Cache::NullStore.new
    Rack::Attack.enabled = false
  end

  # ---------------------------------------------------------------------------
  # Login — per IP throttle (5 req / 20s default)
  # ---------------------------------------------------------------------------
  test "POST /login returns 429 after exceeding IP limit" do
    limit = ENV.fetch("RACK_ATTACK_LOGIN_LIMIT", 5).to_i

    limit.times do
      post login_path,
           params: { email: "attacker@example.com", password: "wrong" },
           env: { "REMOTE_ADDR" => EXTERNAL_IP }
    end

    post login_path,
         params: { email: "attacker@example.com", password: "wrong" },
         env: { "REMOTE_ADDR" => EXTERNAL_IP }

    assert_equal 429, response.status
    assert response.headers["Retry-After"].present?, "Expected Retry-After header"
  end

  # ---------------------------------------------------------------------------
  # Signup — per IP throttle (3 req / 1min default)
  # ---------------------------------------------------------------------------
  test "POST /signup returns 429 after exceeding IP limit" do
    limit = ENV.fetch("RACK_ATTACK_SIGNUP_LIMIT", 3).to_i

    limit.times do |i|
      post signup_path,
           params: {
             registration: {
               email: "user#{i}@example.com",
               password: "password123",
               password_confirmation: "password123",
               first_name: "Test",
               last_name: "User"
             }
           },
           env: { "REMOTE_ADDR" => EXTERNAL_IP }
    end

    post signup_path,
         params: {
           registration: {
             email: "overflow@example.com",
             password: "password123",
             password_confirmation: "password123",
             first_name: "Test",
             last_name: "User"
           }
         },
         env: { "REMOTE_ADDR" => EXTERNAL_IP }

    assert_equal 429, response.status
  end

  # ---------------------------------------------------------------------------
  # Forgot password — per IP throttle (3 req / 1min default)
  # ---------------------------------------------------------------------------
  test "POST /forgot-password returns 429 after exceeding IP limit" do
    limit = ENV.fetch("RACK_ATTACK_FORGOT_PASSWORD_LIMIT", 3).to_i

    limit.times do
      post forgot_password_path,
           params: { email: "victim@example.com" },
           env: { "REMOTE_ADDR" => EXTERNAL_IP }
    end

    post forgot_password_path,
         params: { email: "victim@example.com" },
         env: { "REMOTE_ADDR" => EXTERNAL_IP }

    assert_equal 429, response.status
  end

  # ---------------------------------------------------------------------------
  # Resend verification — per IP throttle (3 req / 1min default)
  # ---------------------------------------------------------------------------
  test "POST /resend-verification returns 429 after exceeding IP limit" do
    limit = ENV.fetch("RACK_ATTACK_RESEND_VERIFICATION_LIMIT", 3).to_i

    limit.times do
      post resend_verification_path,
           env: { "REMOTE_ADDR" => EXTERNAL_IP }
    end

    post resend_verification_path,
         env: { "REMOTE_ADDR" => EXTERNAL_IP }

    assert_equal 429, response.status
  end

  # ---------------------------------------------------------------------------
  # Safelisted endpoint — GET /up must never be throttled
  # ---------------------------------------------------------------------------
  test "GET /up is never throttled regardless of request count" do
    20.times { get "/up", env: { "REMOTE_ADDR" => EXTERNAL_IP } }
    assert_not_equal 429, response.status
  end

  # ---------------------------------------------------------------------------
  # Response format — browser requests receive HTML 429 page
  # ---------------------------------------------------------------------------
  test "throttled browser request returns HTML response" do
    limit = ENV.fetch("RACK_ATTACK_LOGIN_LIMIT", 5).to_i

    (limit + 1).times do
      post login_path,
           params: { email: "attacker@example.com", password: "wrong" },
           headers: { "Accept" => "text/html,application/xhtml+xml" },
           env: { "REMOTE_ADDR" => EXTERNAL_IP }
    end

    assert_equal 429, response.status
    assert_includes response.headers["Content-Type"], "text/html"
    assert_includes response.body, "Too many requests"
  end

  # ---------------------------------------------------------------------------
  # Response format — non-browser requests receive JSON 429 response
  # ---------------------------------------------------------------------------
  test "throttled non-browser request returns JSON response" do
    limit = ENV.fetch("RACK_ATTACK_LOGIN_LIMIT", 5).to_i

    # Warm up the counter using the default Accept header (avoids MissingTemplate
    # from the sessions controller when rendering a failed login as JSON).
    limit.times do
      post login_path,
           params: { email: "attacker@example.com", password: "wrong" },
           env: { "REMOTE_ADDR" => EXTERNAL_IP }
    end

    # The (limit + 1)th request — now throttled — asks for JSON.
    post login_path,
         params: { email: "attacker@example.com", password: "wrong" },
         headers: { "Accept" => "application/json" },
         env: { "REMOTE_ADDR" => EXTERNAL_IP }

    assert_equal 429, response.status
    assert_includes response.headers["Content-Type"], "application/json"

    parsed = JSON.parse(response.body)
    assert parsed.key?("error"), "Expected 'error' key in JSON response"
    assert parsed.key?("retry_after"), "Expected 'retry_after' key in JSON response"
  end
end
