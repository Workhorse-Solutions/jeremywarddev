# PRD: AccountScoped Concern

## Prerequisites

None — this is the first PRD in the sequence.

## Introduction

Extract an `AccountScoped` concern that provides `belongs_to :account`, validation,
and helper scopes for any model that belongs to an Account. This reduces boilerplate
for every new domain model and enforces consistent multitenancy patterns.

Update the `add_model` skill to auto-include this concern by default.

This is a **core template responsibility** — multitenancy isolation is fundamental.

## Goals

- Eliminate repeated `belongs_to :account` + validation boilerplate across models
- Provide standard scoping helpers for querying within an account
- Update the `add_model` skill to include the concern automatically
- Keep the concern minimal and non-magical (no default_scope)

## User Stories

### ASC-001: Create AccountScoped concern

**Description:** As a developer, I want a reusable concern for Account-scoped models so that I don't repeat the same boilerplate in every model.

**Acceptance Criteria:**
- [x] `AccountScoped` concern exists at `app/models/concerns/account_scoped.rb`
- [x] Concern adds `belongs_to :account`
- [x] Concern validates presence of account association
- [x] Concern adds a `.for_account(account)` scope that filters by account
- [x] Concern adds a `.for_current_account` scope that filters records to the account set in the current request context; raises an error if no current account is set
- [x] `bin/ci` passes

### ASC-002: Apply concern to existing Invitation model

**Description:** As a developer, I want the existing Invitation model to use the AccountScoped concern so that the pattern is consistent.

**Acceptance Criteria:**
- [x] Invitation model includes `AccountScoped` instead of manually declaring `belongs_to :account`
- [x] Invitation model behavior is unchanged (all existing tests still pass)
- [x] `bin/ci` passes

### ASC-003: Add concern tests

**Description:** As a developer, I want test coverage for the AccountScoped concern so that its behavior is verified.

**Acceptance Criteria:**
- [x] Tests verify that including the concern adds the account association
- [x] Tests verify the `.for_account(account)` scope returns only records for that account
- [x] Tests verify the `.for_current_account` scope returns records scoped to the current request context's account
- [x] Tests verify that `.for_current_account` raises an error when no current account is set
- [x] Tests verify that a record without an account is invalid
- [x] `bin/ci` passes

### ASC-004: Update add_model skill to auto-include AccountScoped

**Description:** As a developer using the `add_model` skill, I want new models to automatically include `AccountScoped` so that multitenancy is enforced by default.

**Acceptance Criteria:**
- [x] The `add_model` skill generates models with `include AccountScoped` instead of manual `belongs_to :account`
- [x] The skill still generates the `account_id` foreign key in the migration
- [x] Generated model tests verify account scoping via the concern
- [x] The `add_model` skill's SKILL.md shows `include AccountScoped` in the model template instead of manual `belongs_to :account`
- [x] `bin/ci` passes

## Functional Requirements

- FR-1: Create `AccountScoped` concern with `belongs_to :account` and presence validation
- FR-2: Add `.for_account(account)` class method that returns `where(account: account)`
- FR-3: Add `.for_current_account` class method that returns `where(account: Current.account)`; raises if `Current.account` is nil
- FR-4: Refactor Invitation model to use the concern
- FR-5: Update `add_model` skill to include the concern in generated models

## Non-Goals

- No `default_scope` — explicit scoping is a RailsFoundry convention
- No automatic Current.account injection into queries (too magical)
- No changes to AccountUser model (it's a join table with different semantics)
- No changes to the Account or User models
- No optional uniqueness helper — declare uniqueness validations per-model

## Technical Considerations

- The concern should be a standard `ActiveSupport::Concern` with `extend ActiveSupport::Concern`
- `.for_current_account` raises if `Current.account` is nil to catch scoping bugs early. Background jobs that need account scoping should pass the account explicitly via `.for_account(account)`.
- The Invitation model already has `belongs_to :account` — refactoring it is a safe proof-of-concept

## Success Metrics

- Every new model created via `add_model` automatically includes `AccountScoped`
- Existing Invitation model works identically after refactoring
- Zero boilerplate for account association in new models

## Implementation Sequencing Plan

| Order | Story | Depends On | Reason |
|---|---|---|---|
| 1 | ASC-001: Create concern | — | Foundation; must exist before it can be used |
| 2 | ASC-003: Add concern tests | ASC-001 | Tests the concern in isolation |
| 3 | ASC-002: Apply to Invitation | ASC-001, ASC-003 | Proves the concern works with a real model |
| 4 | ASC-004: Update add_model skill | ASC-001 | Skill references the concern |
