# PRD: Feature Flags Generator

## Prerequisites

None — the FeatureFlag model uses a nullable `account_id` directly rather than the AccountScoped concern (since global flags have no account).

## Introduction

Create a Rails generator that installs a simple, database-backed feature flag
system. Flags are Account-scoped, allowing per-tenant feature toggling. The system
is intentionally minimal — a single model and a query interface, not a full
feature management platform.

This is a **generator capability** — feature flags are useful but not required by
every app.

## Goals

- Provide a simple `Feature.enabled?(:flag_name, account)` interface
- Store flags in the database (no external service dependency)
- Support Account-scoped flags (per-tenant) and global flags
- Keep the implementation minimal and easy to understand
- Include a basic admin interface for managing flags

## User Stories

### FF-001: Feature flag model and migration

**Description:** As a developer, I want a FeatureFlag model so that I can store and query feature toggles in the database.

**Acceptance Criteria:**
- [ ] Generator creates a `FeatureFlag` model with fields: `name` (string, required), `account_id` (nullable — null means global), `enabled` (boolean, default false)
- [ ] Unique index on `[name, account_id]` prevents duplicate flags
- [ ] Model validates presence of name
- [ ] Model validates uniqueness of name scoped to account_id
- [ ] Generator installs model tests for FeatureFlag
- [ ] `bin/ci` passes

### FF-002: Feature query interface

**Description:** As a developer, I want a clean `Feature.enabled?(:name, account)` API so that I can check flags anywhere in the app.

**Acceptance Criteria:**
- [ ] Generator creates a `Feature` module with an `.enabled?(name, account = nil)` method
- [ ] Method checks for an account-specific flag first, then falls back to the global flag (account-specific flags override global flags)
- [ ] If no flag exists for the given name, returns false (off by default)
- [ ] Calling `Feature.enabled?` multiple times for the same flag within a single request does not execute additional database queries (cached via `Current` attributes)
- [ ] Generator installs tests for the Feature query interface (account-specific, global, fallback, caching)
- [ ] `bin/ci` passes

### FF-003: Controller helper

**Description:** As a developer, I want a convenient helper to check feature flags in controllers and views.

**Acceptance Criteria:**
- [ ] Generator adds a `feature_enabled?(:name)` helper method available in controllers and views
- [ ] Helper automatically passes `Current.account` as the account context
- [ ] Helper is available in controllers inheriting from `Authenticated::BaseController` and `Admin::BaseController`, and in their corresponding views
- [ ] `bin/ci` passes

### FF-004: Admin flag management

**Description:** As an admin, I want to create, enable, and disable feature flags so that I can control feature rollout.

**Acceptance Criteria:**
- [ ] Generator creates an Admin::FeatureFlagsController with index, create, update, and destroy actions
- [ ] Admin index page lists all flags grouped by global vs account-specific
- [ ] Admin can create a new global flag or an account-specific flag
- [ ] Admin can toggle a flag's enabled state
- [ ] Admin can delete a flag
- [ ] Route is added under the admin namespace
- [ ] Generator installs controller tests for admin CRUD actions
- [ ] `bin/ci` passes
- [ ] **[UI story]** Admin users see a "Feature Flags" section in the admin sidebar with a table of flags and toggle controls

## Functional Requirements

- FR-1: `FeatureFlag` model with name, account_id (nullable), and enabled fields
- FR-2: `Feature.enabled?(:name, account)` query method with account → global fallback
- FR-3: Per-request caching of flag lookups via `Current` attributes (not RequestStore)
- FR-4: `feature_enabled?(:name)` controller/view helper using Current.account
- FR-5: Admin CRUD for creating, toggling, and deleting flags
- FR-6: Admin UI integrated into existing admin layout and sidebar
- FR-7: Test files distributed per-story

## Non-Goals

- No percentage-based rollouts or A/B testing
- No user-level flags (Account-scoped or global only)
- No flag audit log or history
- No external feature flag service integration (LaunchDarkly, Flipper, etc.)
- No scheduled flag activation/deactivation
- No API endpoint for flags
- No `Feature.enable!` / `Feature.disable!` convenience methods (use standard ActiveRecord)
- No flag name validation against a known list — free-form strings

## Technical Considerations

- The `account_id` column should be nullable with a unique index on `[name, account_id]` — this naturally handles the global (null) case
- Per-request caching uses `Current` attributes (already in the codebase), not `RequestStore` (not in Gemfile)
- The admin UI should reuse existing admin layout and table components
- The generator should live in the `rails_foundry_cli` gem

## Success Metrics

- Checking a feature flag is a single method call
- Flag queries don't introduce N+1 problems
- Admin can manage flags without touching the console

## Implementation Sequencing Plan

| Order | Story | Depends On | Reason |
|---|---|---|---|
| 1 | FF-001: Model + migration (with tests) | — | Foundation; all other stories need the schema |
| 2 | FF-002: Query interface (with tests) | FF-001 | Needs model to query |
| 3 | FF-003: Controller helper | FF-002 | Wraps the query interface |
| 4 | FF-004: Admin management (with tests) | FF-001, FF-002 | Needs model and query interface |
