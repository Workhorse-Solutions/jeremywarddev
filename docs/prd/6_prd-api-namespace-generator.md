# PRD: API Namespace Generator

## Prerequisites

- **PRD 1 (AccountScoped Concern)** must be completed first. The ApiKey model uses `include AccountScoped`.

## Introduction

Create a Rails generator that installs an `Api::` controller namespace with token-based
authentication, versioned routing, and JSON response conventions. This enables
RailsFoundry apps to serve mobile clients, third-party integrations, and external
API consumers.

This is a **generator capability** — not every SaaS needs a public API, but when
it's needed, it should follow consistent conventions.

## Goals

- Provide a one-command install for API infrastructure
- Use token-based authentication (API keys per account)
- Support API versioning via URL prefix (`/api/v1/`)
- Follow simple JSON response conventions
- Include rate limiting integration (extend Rack::Attack if installed)
- Generate base controllers, authentication concern, and example endpoint

## User Stories

### API-001: Generator scaffold with base controller and routes

**Description:** As a developer, I want to run a generator to install API infrastructure so that I have a consistent starting point for building API endpoints.

**Acceptance Criteria:**
- [ ] Generator is invocable via `rails generate rails_foundry_cli:api`
- [ ] Generator creates `Api::BaseController` inheriting from `ActionController::API`
- [ ] Generator creates `Api::V1::BaseController` inheriting from `Api::BaseController`
- [ ] Generator adds versioned API routes under `/api/v1/` namespace
- [ ] Base controller includes standard JSON error handling (401, 404, 422, 500)
- [ ] Generator installs controller tests for base error handling
- [ ] `bin/ci` passes

### API-002: API key model and migration

**Description:** As a developer, I want an ApiKey model so that accounts can authenticate API requests with bearer tokens.

**Acceptance Criteria:**
- [ ] Generator creates an `ApiKey` model belonging to Account (via AccountScoped)
- [ ] Migration adds fields for token (unique, indexed), name (human label), last_used_at, and revoked_at
- [ ] Token is generated automatically on creation and is cryptographically secure (at least 32 bytes of entropy)
- [ ] Model provides `.active` scope (not revoked)
- [ ] Full token value is available immediately after creation
- [ ] After initial creation, only the last 4 characters of the token are retrievable
- [ ] Generator installs model tests for ApiKey (token generation, scopes, revocation)
- [ ] `bin/ci` passes

### API-003: Token authentication concern

**Description:** As a developer, I want API requests authenticated via bearer tokens so that only authorized accounts can access the API.

**Acceptance Criteria:**
- [ ] Generator creates an `ApiAuthenticatable` concern for API controllers
- [ ] Concern reads bearer token from the `Authorization` header
- [ ] Concern looks up the ApiKey matching the provided bearer token
- [ ] Concern sets `Current.account` from the authenticated ApiKey's account
- [ ] Concern records `last_used_at` timestamp on the ApiKey
- [ ] Missing or invalid tokens return 401 with a JSON error body
- [ ] Revoked tokens return 401
- [ ] `Api::V1::BaseController` includes the concern by default
- [ ] Generator installs controller tests for authentication (valid/invalid/missing/revoked tokens)
- [ ] `bin/ci` passes

### API-004: Example health endpoint

**Description:** As a developer, I want an example API endpoint so that I can verify the installation works and see the conventions in action.

**Acceptance Criteria:**
- [ ] Generator creates `Api::V1::HealthController` with a `show` action
- [ ] Health endpoint returns `{ "status": "ok", "timestamp": "..." }` as JSON
- [ ] Health endpoint is accessible without authentication (safelisted)
- [ ] Route is `GET /api/v1/health`
- [ ] Generator installs controller tests for the health endpoint
- [ ] `bin/ci` passes

### API-005: API rate limiting (if Rack::Attack is configured)

**Description:** As a developer, I want API endpoints rate-limited so that a single consumer can't overwhelm the system.

**Acceptance Criteria:**
- [ ] If Rack::Attack initializer exists, generator appends API-specific throttle rules
- [ ] API requests are throttled per-token at a configurable default rate (e.g., 60 requests per minute)
- [ ] Throttled API requests return 429 JSON response with `retry_after` field
- [ ] If Rack::Attack is not installed, this step is skipped with a message
- [ ] `bin/ci` passes

## Functional Requirements

- FR-1: Generator creates API controller hierarchy (`Api::BaseController` → `Api::V1::BaseController`)
- FR-2: Generator creates ApiKey model with secure token generation
- FR-3: Bearer token authentication via `Authorization` header
- FR-4: JSON error responses for 401, 404, 422, and 500
- FR-5: Versioned routing under `/api/v1/`
- FR-6: Example health endpoint for verification
- FR-7: Optional Rack::Attack integration for API rate limiting
- FR-8: Generator installs test files per-story

## Non-Goals

- No OAuth2 or JWT — simple bearer tokens only
- No API documentation generation (Swagger/OpenAPI)
- No pagination helpers (use Pagy if needed, already in the app)
- No GraphQL
- No API key management UI (admin can manage via console or future admin page)
- No per-endpoint scoping or permissions on API keys
- No CORS configuration (can be added separately if needed for browser-based consumers)
- No User-associated API keys — Account-scoped only

## Technical Considerations

- `Api::BaseController` should inherit from `ActionController::API`, not `ApplicationController`, for performance (no session, cookies, CSRF)
- Token lookup should be constant-time (`find_by(token:)` with database index) to prevent timing attacks
- API versioning via URL prefix is simplest and most explicit — no header-based versioning
- The generator should live in the `rails_foundry_cli` gem

## Success Metrics

- Developer can install and make an authenticated API request within 5 minutes
- API authentication is secure (bearer tokens, constant-time lookup)
- Generated tests pass in CI

## Implementation Sequencing Plan

| Order | Story | Depends On | Reason |
|---|---|---|---|
| 1 | API-001: Base controller + routes (with tests) | — | Foundation; defines the namespace and routing |
| 2 | API-002: ApiKey model + migration (with tests) | — | Independent of controllers; provides auth data model |
| 3 | API-003: Token auth concern (with tests) | API-001, API-002 | Needs controller to include it and model to query |
| 4 | API-004: Health endpoint (with tests) | API-001 | Needs base controller and routes |
| 5 | API-005: Rate limiting | API-001, API-003 | Needs API namespace and auth context |
