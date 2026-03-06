# PRD: Rack::Attack Security Hardening

## Prerequisites

None — this PRD is independent.

## Introduction

Add a Rack::Attack initializer to the core template that rate-limits authentication
endpoints. The `rack-attack` gem is already in the Gemfile but has no configuration.
Every SaaS application needs rate limiting on auth endpoints to prevent credential
stuffing, brute-force attacks, and abuse of email-sending endpoints.

This is a **core template responsibility** — not a generator.

## Goals

- Protect authentication endpoints (login, registration, password reset, email verification) from abuse
- Use compound throttling (per-IP + per-email) to defend against distributed credential stuffing
- Provide sensible hardcoded defaults with optional ENV overrides for per-app tuning
- Return appropriate 429 responses (HTML for browsers, JSON for non-browser clients)
- Safelist health check and internal monitoring endpoints

## User Stories

### RAT-001: Create Rack::Attack initializer with auth throttles

**Description:** As a developer, I want auth endpoints rate-limited out of the box so that my app is protected from brute-force attacks without manual configuration.

**Acceptance Criteria:**
- [x] Rack::Attack initializer exists at `config/initializers/rack_attack.rb`
- [x] Login endpoint (`POST /login`) is throttled per-IP (e.g., 5 requests per 20 seconds)
- [x] Login endpoint is also throttled per-email parameter (e.g., 10 requests per 15 minutes) to prevent credential stuffing across IPs
- [x] Registration endpoint (`POST /signup`) is throttled per-IP (e.g., 3 requests per minute)
- [x] Password reset endpoint (`POST /forgot-password`) is throttled per-IP and per-email
- [x] Email verification resend endpoint (`POST /email-verification/resend` and `POST /resend-verification`) is throttled per-IP
- [x] `bin/ci` passes

### RAT-002: Add safelist and blocklist configuration

**Description:** As a developer, I want health checks safelisted and a clear extension point for custom blocklists so that monitoring works and I can block known bad actors.

**Acceptance Criteria:**
- [x] Health check endpoint (`GET /up`) is safelisted from all throttles
- [x] Localhost/loopback IPs are safelisted
- [x] Configuration includes commented examples showing how to add IP blocklists and custom safelists
- [x] `bin/ci` passes

### RAT-003: Custom throttle response with format detection

**Description:** As a user, I want to see a clear error message when I'm rate-limited, not a raw error page.

**Acceptance Criteria:**
- [x] Throttled requests return HTTP 429 status with `Retry-After` header
- [x] Browser requests (Accept: text/html) receive a static error page at `public/429.html`
- [x] Non-browser requests receive a JSON response with error message and retry_after value
- [x] Throttle events are logged at `Rails.logger.warn` level with throttle name, discriminator, and request path
- [x] `bin/ci` passes
- [x] **[UI story]** Throttled browser requests render an error page with a human-readable message indicating the user should wait before trying again

### RAT-004: ENV-based threshold overrides

**Description:** As a developer deploying to different environments, I want to tune rate limits via ENV vars without editing the initializer.

**Acceptance Criteria:**
- [x] Each throttle rule reads from an ENV var with a hardcoded fallback default
- [x] ENV var naming follows a consistent pattern (e.g., `RACK_ATTACK_LOGIN_LIMIT`, `RACK_ATTACK_LOGIN_PERIOD`)
- [x] `.env.example` is updated with the available ENV vars and their defaults (commented out)
- [x] `bin/ci` passes

### RAT-005: Integration tests for throttle rules

**Description:** As a developer, I want test coverage for rate limiting so that throttle rules don't silently break.

**Acceptance Criteria:**
- [x] Integration tests verify that auth endpoints return 429 after exceeding the throttle limit
- [x] Tests verify that safelisted endpoints are not throttled
- [x] Tests verify both HTML and JSON response formats for throttled requests
- [x] `bin/ci` passes

## Functional Requirements

- FR-1: Rate-limit `POST /login` by IP address (default: 5 req/20s) and by email parameter (default: 10 req/15min)
- FR-2: Rate-limit `POST /signup` by IP address (default: 3 req/min)
- FR-3: Rate-limit `POST /forgot-password` by IP address (default: 3 req/min) and by email parameter (default: 5 req/hour)
- FR-4: Rate-limit email verification resend endpoints by IP address (default: 3 req/min)
- FR-5: Safelist `GET /up` and loopback IPs from all throttles
- FR-6: Return 429 with `Retry-After` header; static HTML page for browser requests, JSON for others
- FR-7: All thresholds and periods configurable via ENV vars with hardcoded fallback defaults
- FR-8: Log throttle events at warn level for monitoring

## Non-Goals

- No fail2ban-style progressive blocking (can be added later if needed)
- No general request throttle for non-auth endpoints (will be addressed in API namespace generator)
- No admin UI for managing blocked IPs
- No Redis dependency — use Rack::Attack's default cache store (Rails.cache)
- No CAPTCHA integration

## Technical Considerations

- Rack::Attack uses `Rails.cache` as its backing store by default. Solid Cache (already configured) is sufficient.
- Throttle discriminators should normalize email addresses (downcase, strip) to prevent bypass via case variation.
- The `request.ip` may need attention behind load balancers — document that `config.action_dispatch.trusted_proxies` should be configured in production.
- Use a static file at `public/429.html` for throttled browser responses, matching the Rails convention for error pages (`public/404.html`, `public/500.html`).

## Success Metrics

- All auth endpoints return 429 when thresholds are exceeded
- Zero additional gems required (rack-attack already in Gemfile)
- Initializer is self-documenting with inline comments

## Implementation Sequencing Plan

| Order | Story | Depends On | Reason |
|---|---|---|---|
| 1 | RAT-001: Initializer with auth throttles | — | Foundation; defines all throttle rules |
| 2 | RAT-002: Safelist and blocklist config | RAT-001 | Adds to the initializer created in RAT-001 |
| 3 | RAT-003: Custom throttle response | RAT-001 | Configures response behavior for throttled requests |
| 4 | RAT-004: ENV-based overrides | RAT-001 | Refactors hardcoded values to read from ENV |
| 5 | RAT-005: Integration tests | RAT-001, RAT-002, RAT-003, RAT-004 | Tests all behavior from prior stories |
