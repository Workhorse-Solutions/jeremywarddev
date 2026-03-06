# PRD: Solid Queue Production Configuration

## Prerequisites

None — this PRD is independent.

## Introduction

Enhance the existing Solid Queue configuration with named priority queues and ensure
ActionMailer delivers via `deliver_later` through Solid Queue. The gem is already
in the Gemfile, the adapter is set for production, and `config/queue.yml` exists
with basic worker/dispatcher configuration. This PRD adds named queue topology
and verifies end-to-end async email delivery.

This is a **core template responsibility** — every SaaS app needs working
background jobs and async email delivery.

## Goals

- Define named queues with priority ordering (default, mailers, billing)
- Ensure ActionMailer uses `deliver_later` with Solid Queue in all environments
- Enhance existing production-ready queue configuration
- Keep the configuration minimal and easy to extend

## User Stories

### SQP-001: Define named queues with priority ordering

**Description:** As a developer, I want named queues with clear priority so that critical jobs (billing) are processed before bulk work.

**Acceptance Criteria:**
- [x] Solid Queue configuration in `config/queue.yml` defines at least three queues: `default`, `mailers`, `billing`
- [x] Queue priority ordering is explicit: `billing` > `mailers` > `default`
- [x] Workers are configured per-queue (not just wildcard `*`)
- [x] `bin/ci` passes

### SQP-002: Configure ActionMailer for async delivery

**Description:** As a developer, I want all mailers to deliver asynchronously via Solid Queue so that email sending never blocks request threads.

**Acceptance Criteria:**
- [x] ActionMailer is configured to use the `mailers` queue for `deliver_later`
- [x] Production uses `:solid_queue` adapter (already set — verify)
- [x] Development uses `letter_opener_web` delivery method with async adapter
- [x] Test uses `:test` delivery method
- [x] Existing mailers (UserMailer, InvitationMailer) enqueue to the `mailers` queue when called with `deliver_later`
- [x] `bin/ci` passes

### SQP-003: Verify and document worker configuration

**Description:** As a developer deploying to production, I want the existing Solid Queue worker configuration verified and documented.

**Acceptance Criteria:**
- [x] Existing worker configuration in `config/queue.yml` is updated to process named queues with priority ordering instead of wildcard `*`
- [x] Puma plugin for Solid Queue (`plugin :solid_queue`) is documented as an alternative to `bin/jobs`
- [x] `bin/ci` passes

### SQP-004: Add test coverage for queue configuration

**Description:** As a developer, I want to verify that jobs are enqueued to the correct queues.

**Acceptance Criteria:**
- [x] Test verifies that mailers enqueue to the `mailers` queue
- [x] Test verifies that the production queue adapter is `:solid_queue`
- [x] `bin/ci` passes

## Functional Requirements

- FR-1: Define `billing`, `mailers`, and `default` queues in `config/queue.yml`
- FR-2: Set queue priority: billing (highest), mailers, default (lowest)
- FR-3: Configure ActionMailer `deliver_later` to use the `mailers` queue
- FR-4: Update existing workers to process named queues with priority ordering
- FR-5: Ensure `bin/jobs` starts Solid Queue workers correctly

## Non-Goals

- No new recurring/scheduled job infrastructure (a recurring job for clearing finished jobs already exists in `config/recurring.yml`)
- No job monitoring UI or dashboard
- No dead letter queue or custom retry policies beyond Solid Queue defaults
- No Redis dependency
- No dedicated worker process for the billing queue (use priority ordering; share workers)

## Technical Considerations

- `config/queue.yml` already exists with worker (threads: 3, processes: configurable via JOB_CONCURRENCY) and dispatcher (polling_interval: 1, batch_size: 500) configuration. This PRD enhances it with named queues.
- Production already has `config.active_job.queue_adapter = :solid_queue`. Development defaults to `:async` (Rails default).
- Puma plugin for Solid Queue is already configured in `config/puma.rb` (`plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]`).
- Default concurrency: keep existing `threads: 3`, tunable via `JOB_CONCURRENCY` env var for process count.

## Success Metrics

- All existing mailers deliver via background jobs, not inline
- Jobs are routed to the correct named queue
- `bin/jobs` starts and processes jobs from all configured queues

## Implementation Sequencing Plan

| Order | Story | Depends On | Reason |
|---|---|---|---|
| 1 | SQP-001: Named queues with priority | — | Foundation; defines queue topology |
| 2 | SQP-002: ActionMailer async delivery | SQP-001 | Needs mailers queue defined |
| 3 | SQP-003: Verify worker config | SQP-001 | Needs queue definitions in place |
| 4 | SQP-004: Test coverage | SQP-001, SQP-002 | Tests the full configuration |
