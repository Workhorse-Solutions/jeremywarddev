---
name: prd
description: "Generate a Product Requirements Document (PRD) for a new feature. Use when asked to create a prd, write prd for, plan this feature, requirements for, or spec out a feature. Produces a structured markdown PRD only — never implements code."
---

# PRD Generator — RailsFoundry

Create clear, actionable Product Requirements Documents suitable for
implementation in a RailsFoundry-based application.

This skill generates PRD markdown files only.
**Do NOT start implementing code.**
**After saving the PRD, remind the user to run `review_prd` before `work_prd`.**

---

## The Job

1. Receive a feature description from the user
2. Ask 3–5 essential clarifying questions (with lettered options)
3. Generate a structured PRD based on answers
4. Save to `docs/prd/prd-<feature-name>.md`

**Important:** Do NOT start implementing. Just create the PRD.

---

## RailsFoundry Platform Capabilities

Before writing any story, check whether the requirement is already solved by the
stack. Do not write acceptance criteria that re-implement what the platform provides.

| Concern | What Rails/RailsFoundry already provides | Do NOT spec |
|---|---|---|
| Password reset tokens | `has_secure_password reset_token: { expires_in: N }` — signed tokens, no DB column, auto-invalidates on password change | Custom token columns, `SecureRandom` tokens, manual expiry checks |
| Custom signed tokens | `generates_token_for :purpose, expires_in: N do … end` — fingerprinted, expiring, no DB column | Token columns, timestamp-based expiry |
| Rate limiting | `rack-attack` is already configured | Custom rate limit logic in controllers |
| Background jobs | Solid Queue is configured; use `deliver_later` / `perform_later` | Custom job infrastructure |
| Session management | `reset_session` and `session[:key]` are standard Rails | Custom session stores |
| CSRF protection | `protect_from_forgery` is on by default | Custom CSRF logic |
| Email previews (dev) | `letter_opener_web` is configured; previews go in `test/mailers/previews/` | External SMTP in development |
| Auth base classes | `Public::BaseController` and `Authenticated::BaseController` exist | New base controller hierarchies |

If a requirement touches these areas, write criteria at the **behaviour level**
(what the system must do), not the **implementation level** (how to build it).
Let the implementing agent choose the idiomatic Rails approach.

---

## Step 1: Clarifying Questions

Ask only critical questions where the initial prompt is ambiguous. Focus on:

- **Problem/Goal:** What problem does this solve?
- **Core Functionality:** What are the key actions?
- **Scope/Boundaries:** What should it NOT do?
- **Success Criteria:** How do we know it's done?

### Format Questions Like This:

```
1. What is the primary goal of this feature?
   A. Improve user onboarding experience
   B. Increase user retention
   C. Reduce support burden
   D. Other: [please specify]

2. Who is the target user?
   A. New users only
   B. Existing users only
   C. All users
   D. Admin users only

3. What is the scope?
   A. Minimal viable version
   B. Full-featured implementation
   C. Just the backend/API
   D. Just the UI
```

This lets users respond with "1A, 2C, 3B" for quick iteration.
Remember to indent the options.

---

## Step 2: PRD Structure

Generate the PRD with these sections:

### 1. Introduction/Overview
Brief description of the feature and the problem it solves.

### 2. Goals
Specific, measurable objectives (bullet list).

### 3. User Stories

Each story needs:
- **Title:** Short descriptive name
- **Description:** "As a [user], I want [feature] so that [benefit]"
- **Acceptance Criteria:** Verifiable checklist of what "done" means

Each story should be small enough to implement in one focused session.

**Format:**
```markdown
### [FEATURE_ABBREVIATION]-001: [Title]
**Description:** As a [user], I want [feature] so that [benefit].

**Acceptance Criteria:**
- [ ] Concrete, verifiable requirement
- [ ] Another specific requirement
- [ ] All tests pass
- [ ] `bin/ci` passes
- [ ] **[UI story]** [Describe the specific observable outcome: which element is visible/hidden, which text appears, which redirect occurs — e.g., "Unverified users see a banner with 'Resend verification email'; verified users do not"]
```

#### Acceptance Criteria Quality Rules

- **What, not how.** Requirements at behaviour level only. Never prescribe implementation
  mechanism (no column names, gem internals, or method names).
  ✅ "User receives a password reset email with a secure, expiring link"
  ❌ "`generate_password_reset_token!` sets token using `SecureRandom.urlsafe_base64(32)`"
- **Objective and testable.** No vague language: "works correctly", "handles errors",
  "displays nicely". Every criterion must have a clear pass/fail.
- **One thing per bullet.** Split compound criteria into separate bullets.
- **Every story includes `bin/ci` passes.** No exceptions.
- **UI stories include a system test assertion.** Any story that adds or changes a
  user-visible element must include a `[UI story]` bullet. The bullet must describe
  the **specific observable outcome** (element visible/hidden, flash text, redirect
  destination) — not just "verify visually via `bin/dev`". `work_prd` will implement
  this as an automated system test using the `system_test` skill.

Acceptance criteria must be objective and testable.
Avoid vague language like "works correctly" or "verify visually".

### 4. Functional Requirements
Numbered list of specific functionalities:
- "FR-1: The system must allow users to..."
- "FR-2: When a user clicks X, the system must..."

Be explicit and unambiguous.

### 5. Non-Goals (Out of Scope)
What this feature will NOT include. Critical for managing scope.

### 6. Design Considerations (Optional)
- UI/UX requirements
- Link to mockups if available
- Relevant existing components to reuse

### 7. Technical Considerations (Optional)
- Known constraints or dependencies
- Integration points with existing systems
- Performance requirements

### 8. Success Metrics
How will success be measured?
- "Reduce time to complete X by 50%"
- "Increase conversion rate by 10%"

### 9. Open Questions
Remaining questions or areas needing clarification.

### 10. Implementation Sequencing Plan (REQUIRED)

Every PRD **must** end with this table. `work_prd` uses it as the authoritative
implementation order — if it is missing, the agent falls back to document order,
which is often wrong.

**Rules:**
- Migrations before models before mailers before controllers before views before admin.
- Mark the direct dependency for each story explicitly.
- Stories with no inter-dependency may be listed at the same order level.

```markdown
## Implementation Sequencing Plan

| Order | Story | Depends On | Reason |
|---|---|---|---|
| 1 | FEAT-001: Database migration | — | Foundation; all other stories need the schema |
| 2 | FEAT-002: Model methods | FEAT-001 | Needs columns in place |
| 3 | FEAT-003: Mailer | FEAT-002 | Needs model helpers |
| 4 | FEAT-004: Controller | FEAT-002, FEAT-003 | Needs model + mailer |
| 5 | FEAT-005: Views/UI | FEAT-004 | Needs routes and controller |
```

---

## Writing for Junior Developers

The PRD reader may be a junior developer or AI agent. Therefore:

- Be explicit and unambiguous
- Avoid jargon or explain it
- Provide enough detail to understand purpose and core logic
- Number requirements for easy reference
- Use concrete examples where helpful

---

## Output

- **Format:** Markdown (`.md`)
- **Location:** `docs/prd/`
- **Filename:** `prd-<feature-name>.md` (kebab-case)
- **After saving:** Remind the user to run `review_prd` on the file before
  starting implementation with `work_prd`.

---

## Example PRD

```markdown
# PRD: Task Priority System

## Introduction

Add priority levels to tasks so users can focus on what matters most. Tasks can
be marked as high, medium, or low priority, with visual indicators and filtering
to help users manage their workload effectively.

## Goals

- Allow assigning priority (high/medium/low) to any task
- Provide clear visual differentiation between priority levels
- Enable filtering and sorting by priority
- Default new tasks to medium priority

## User Stories

### TP-001: Add priority field to database
**Description:** As a developer, I need to store task priority so it persists across sessions.

**Acceptance Criteria:**
- [ ] Add priority column to tasks table: 'high' | 'medium' | 'low' (default 'medium')
- [ ] Generate and run migration successfully
- [ ] All tests pass
- [ ] `bin/ci` passes

### TP-002: Display priority indicator on task cards
**Description:** As a user, I want to see task priority at a glance so I know what needs attention first.

**Acceptance Criteria:**
- [ ] Each task card shows colored priority badge (red=high, yellow=medium, gray=low)
- [ ] Priority visible without hovering or clicking
- [ ] All tests pass
- [ ] `bin/ci` passes
- [ ] **[UI story]** Verify visually via `bin/dev`

### TP-003: Add priority selector to task edit
**Description:** As a user, I want to change a task's priority when editing it.

**Acceptance Criteria:**
- [ ] Priority dropdown in task edit modal
- [ ] Shows current priority as selected
- [ ] Saves immediately on selection change
- [ ] All tests pass
- [ ] `bin/ci` passes
- [ ] **[UI story]** Verify visually via `bin/dev`

### TP-004: Filter tasks by priority
**Description:** As a user, I want to filter the task list to see only high-priority items when focused.

**Acceptance Criteria:**
- [ ] Filter dropdown with options: All | High | Medium | Low
- [ ] Filter persists in URL params
- [ ] Empty state message when no tasks match filter
- [ ] All tests pass
- [ ] `bin/ci` passes
- [ ] **[UI story]** Verify visually via `bin/dev`

## Functional Requirements

- FR-1: Add `priority` field to tasks table ('high' | 'medium' | 'low', default 'medium')
- FR-2: Display colored priority badge on each task card
- FR-3: Include priority selector in task edit modal
- FR-4: Add priority filter dropdown to task list header
- FR-5: Sort by priority within each status column (high to medium to low)

## Non-Goals

- No priority-based notifications or reminders
- No automatic priority assignment based on due date
- No priority inheritance for subtasks

## Technical Considerations

- Reuse existing badge component with color variants
- Filter state managed via URL search params
- Priority stored in database, not computed

## Success Metrics

- Users can change priority in under 2 clicks
- High-priority tasks immediately visible at top of lists
- No regression in task list performance

## Open Questions

- Should priority affect task ordering within a column?
- Should we add keyboard shortcuts for priority changes?

## Implementation Sequencing Plan

| Order | Story | Depends On | Reason |
|---|---|---|---|
| 1 | TP-001: Add priority field to database | — | Foundation; all other stories need the schema |
| 2 | TP-002: Display priority indicator | TP-001 | Needs column to read from |
| 3 | TP-003: Priority selector in edit | TP-001 | Needs column to write to |
| 4 | TP-004: Filter by priority | TP-001, TP-002, TP-003 | Needs full read/write in place |
```

---

## Checklist

Before saving the PRD:

- [ ] Clarifying questions were asked and answered
- [ ] Incorporated user's answers
- [ ] User stories are small, specific, and testable
- [ ] Acceptance criteria use requirements language (what, not how)
- [ ] No criterion re-implements a platform capability (see table above)
- [ ] Functional requirements are numbered and unambiguous
- [ ] Non-goals section defines clear boundaries
- [ ] UI stories include `bin/dev` verification
- [ ] `bin/ci` is listed in every story's acceptance criteria
- [ ] Implementation Sequencing Plan table is present and dependency order is correct
- [ ] Saved to `docs/prd/prd-<feature-name>.md`
- [ ] Reminded user to run `review_prd` before `work_prd`
