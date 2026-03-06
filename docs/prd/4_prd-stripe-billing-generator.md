# PRD: Stripe Billing Generator

## Prerequisites

- **PRD 1 (AccountScoped Concern)** must be completed first. The Subscription model uses `include AccountScoped`.

## Introduction

Create a Rails generator that installs flat-rate Stripe subscription billing into
a RailsFoundry app. Uses the raw `stripe` gem (already in the Gemfile) with no
additional wrapper gems. Installs a webhook controller, Subscription model,
billing status synchronization, and trial expiry enforcement.

This is a **generator capability** — billing varies by app, but every SaaS needs
a starting point. The generator installs opinionated defaults that developers can
customize after installation.

## Data Architecture Decision

The Account model already has `stripe_customer_id`, `stripe_subscription_id`,
`billing_status`, and `trial_ends_at` columns. The Subscription model adds
Stripe-specific detail without duplicating authority:

- **Account** remains the canonical source for app-level billing checks:
  `stripe_customer_id`, `billing_status`, `trial_ends_at`
- **Subscription** stores Stripe-specific detail: `stripe_subscription_id`,
  `stripe_price_id`, `current_period_start`, `current_period_end`, `cancel_at_period_end`
- **`stripe_subscription_id` moves from Account to Subscription** (migration removes
  it from Account)
- **Webhook sync** writes Stripe details to Subscription, then syncs `billing_status`
  on Account

This avoids two sources of truth. Controllers check `account.billing_status`.
Stripe detail lives on Subscription.

## Goals

- Provide a one-command install for flat-rate Stripe subscription billing
- Handle the full subscription lifecycle: trial → checkout → active → past_due → canceled
- Sync billing status from Stripe webhooks to the Account model
- Enforce trial expiry and subscription requirements at the controller level
- Use raw Stripe API — no additional gems beyond `stripe`
- Generate all necessary migrations, models, controllers, and configuration

## User Stories

### BIL-001: Generator scaffold with Stripe initializer

**Description:** As a developer, I want to run a single generator command to install Stripe billing configuration so that I have a working starting point.

**Acceptance Criteria:**
- [ ] Generator is invocable via `rails generate rails_foundry_cli:billing`
- [ ] Generator creates a Stripe initializer that reads API keys and webhook secret from ENV
- [ ] Generator updates `.env.example` with required Stripe ENV vars
- [ ] Generator is idempotent (safe to re-run)
- [ ] `bin/ci` passes

### BIL-002: Subscription model and migration

**Description:** As a developer, I want a Subscription model to track Stripe subscription detail so that billing state is queryable from the database.

**Acceptance Criteria:**
- [ ] Generator creates a `Subscription` model that belongs to Account (via AccountScoped concern)
- [ ] Subscription tracks Stripe subscription identifier, price identifier, lifecycle status (trialing/active/past_due/canceled/incomplete), current billing period dates, cancellation intent, and trial end date
- [ ] Model validates status inclusion and required fields
- [ ] Account `has_one :subscription`
- [ ] Migration removes `stripe_subscription_id` from the accounts table (moved to Subscription)
- [ ] Generator adds `incomplete` to Account's `BILLING_STATUSES` constant
- [ ] Generator installs model tests for Subscription
- [ ] `bin/ci` passes

### BIL-003: Webhook controller for Stripe events

**Description:** As a developer, I want incoming Stripe webhooks verified and processed so that billing state stays in sync.

**Acceptance Criteria:**
- [ ] Generator creates a webhook controller at an appropriate route (e.g., `POST /webhooks/stripe`)
- [ ] Controller verifies Stripe webhook signatures and rejects requests with invalid signatures (400)
- [ ] Controller handles `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`, and `invoice.payment_failed` events
- [ ] Unhandled event types return 200 (acknowledge but ignore)
- [ ] Controller skips CSRF verification for webhook requests
- [ ] Generator installs controller tests for webhook signature verification and event handling
- [ ] `bin/ci` passes

### BIL-004: Billing status sync from webhooks

**Description:** As a developer, I want subscription status changes from Stripe to automatically update the Account's billing status so that the app reflects reality.

**Acceptance Criteria:**
- [ ] When `customer.subscription.updated` fires, the Subscription record is updated with the new status and period dates
- [ ] When `customer.subscription.deleted` fires, the subscription status is set to `canceled`
- [ ] When `invoice.payment_failed` fires, the subscription status is set to `past_due`
- [ ] Account `billing_status` is synced from the Subscription status after each webhook event
- [ ] `bin/ci` passes

### BIL-005: Checkout and customer portal controller

**Description:** As a user, I want to subscribe to a plan and manage my billing so that I can pay for the service.

**Acceptance Criteria:**
- [ ] Generator creates an Authenticated billing controller with `checkout` and `portal` actions
- [ ] `checkout` action creates a Stripe Checkout Session and redirects to Stripe
- [ ] `portal` action creates a Stripe Customer Portal session and redirects to Stripe
- [ ] If the account has no associated Stripe customer, one is created automatically when initiating checkout
- [ ] Routes are added under the authenticated namespace
- [ ] Generator installs controller tests for checkout and portal actions
- [ ] `bin/ci` passes
- [ ] **[UI story]** "Manage Billing" link appears in account settings for accounts with an active subscription; "Upgrade" link appears for accounts on trial or without a subscription; both redirect to the appropriate Stripe-hosted page

### BIL-006: Trial expiry and subscription enforcement

**Description:** As a developer, I want to enforce that accounts have an active subscription (or valid trial) so that expired trials can't access the app.

**Acceptance Criteria:**
- [ ] Generator creates a `BillingEnforceable` concern for controllers
- [ ] Concern provides a `before_action :require_active_billing!` callback
- [ ] Accounts with `billing_status` of `trialing` and unexpired `trial_ends_at` pass the check
- [ ] Accounts with `billing_status` of `active` pass the check
- [ ] Accounts with `past_due`, `canceled`, `incomplete`, or expired trial are redirected to a billing-required page
- [ ] The billing-required page displays a message indicating the account's trial has expired or subscription is inactive, and includes a prominent link to the checkout flow
- [ ] Concern is NOT auto-included — developers opt in by adding it to their controllers
- [ ] Generator installs integration tests for billing enforcement
- [ ] Generated code includes inline comments explaining Stripe-specific decisions
- [ ] `bin/ci` passes
- [ ] **[UI story]** Users on expired trials see a page explaining they need to subscribe, with a link to checkout

## Functional Requirements

- FR-1: Generator creates Stripe initializer reading from ENV
- FR-2: Generator creates Subscription model with migration (belongs to Account via AccountScoped)
- FR-3: Generator creates webhook controller with signature verification
- FR-4: Webhook handler processes subscription lifecycle events, updates Subscription, and syncs Account `billing_status`
- FR-5: Generator creates checkout/portal controller for Stripe-hosted flows
- FR-6: Generator creates BillingEnforceable concern with opt-in enforcement
- FR-7: Generator creates a billing-required page for expired/canceled accounts
- FR-8: Generator installs routes for webhook, checkout, and portal endpoints
- FR-9: Generator updates `.env.example` with Stripe ENV vars
- FR-10: Generator installs test files for all generated code (distributed per-story)
- FR-11: Generator adds `incomplete` to Account::BILLING_STATUSES
- FR-12: Generator removes `stripe_subscription_id` from accounts table

## Non-Goals

- No per-seat or metered/usage-based billing (flat-rate only)
- No in-app pricing page generation (use existing Landing::PricingSectionComponent)
- No Stripe Elements or in-app card input (use Stripe Checkout hosted page)
- No coupon/discount management
- No multiple subscription support per account
- No invoice history UI
- No pay gem or other wrapper — raw Stripe API only

## Design Considerations

- Account keeps `stripe_customer_id` and `billing_status` as the app-level authority
- Subscription stores Stripe detail (`stripe_subscription_id`, period dates, price)
- The billing-required page should use the `public` layout (user is authenticated but blocked)
- Checkout success/cancel URLs should redirect back to the app
- Default trial length: 14 days (matches existing `registration_form.rb` and `db/seeds.rb`)

## Technical Considerations

- Stripe webhook verification requires the raw request body — the controller must use `request.body.read` before Rails parses it
- The webhook endpoint must skip CSRF protection (`skip_forgery_protection`)
- Stripe Customer creation should be idempotent (check for existing customer before creating)
- All Stripe API calls should happen in background jobs where possible (checkout/portal redirects are synchronous by necessity)
- The generator should be part of the `rails_foundry_cli` gem alongside existing generators
- Webhook processing happens inline with a 200 response (Stripe retries on failure). Background dispatch can be added later if volume warrants it.

## Success Metrics

- Developer can run one generator command and have working Stripe billing
- Webhook events correctly sync subscription status to the database
- Trial expiry enforcement works without manual configuration
- Generated tests pass in CI

## Implementation Sequencing Plan

| Order | Story | Depends On | Reason |
|---|---|---|---|
| 1 | BIL-001: Generator scaffold + initializer | — | Foundation; sets up Stripe gem configuration |
| 2 | BIL-002: Subscription model + migration | BIL-001 | Needs initializer; provides data model for all other stories |
| 3 | BIL-003: Webhook controller | BIL-001 | Needs Stripe config; receives events from Stripe |
| 4 | BIL-004: Billing status sync | BIL-002, BIL-003 | Needs model to write to and webhook controller to receive events |
| 5 | BIL-005: Checkout + portal controller | BIL-001, BIL-002 | Needs Stripe config and customer model |
| 6 | BIL-006: Trial expiry enforcement + documentation | BIL-002, BIL-004 | Needs subscription model and status sync working |
