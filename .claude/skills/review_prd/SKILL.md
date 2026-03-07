```skill
---
name: review_prd
description: >
  Review a PRD for Rails compatibility, acceptance criteria quality, sequencing
  correctness, and implementation readiness. Runs between prd and work_prd.
  Modifies the PRD in place. Never writes application code.
---

# Skill: review_prd

## Goal

Validate a PRD before implementation starts. Catch problems that would cause
mid-story rewrites, Rails anti-patterns, or ambiguous acceptance criteria.

This skill modifies the PRD file only. **Do NOT write application code.**

---

## When to Use

Run `review_prd` after `prd` and before `work_prd`:

```
prd  →  review_prd  →  work_prd
```

It is also appropriate to re-run after significant edits to an existing PRD.

---

## Steps

### 1. Read the full PRD

Read the complete PRD from `docs/prd/`.

Identify:
- Every user story and its acceptance criteria
- The Implementation Sequencing Plan (if present)
- All Open Questions

---

### 2. Run the five review passes

Work through each pass independently. Collect all findings before editing.

---

#### Pass 1 — Rails / RailsFoundry Compatibility

Check every acceptance criterion against what the platform already provides.
Flag any criterion that re-implements a solved problem.

| Concern | What already exists | Flag if you see |
|---|---|---|
| Password reset tokens | `has_secure_password reset_token: { expires_in: N }` — signed, no DB column, auto-invalidates on password change | Token columns, `SecureRandom` manual tokens, `*_sent_at` columns for expiry |
| Custom signed tokens | `generates_token_for :purpose, expires_in: N do … end` — no DB column needed | Token columns, timestamp expiry columns for email verification / email change |
| Rate limiting | `rack-attack` is configured | Custom rate limit logic in controllers |
| Background jobs | Solid Queue + `deliver_later` / `perform_later` | Custom job infrastructure |
| Session management | `reset_session`, `session[:key]` | Custom session stores |
| CSRF | `protect_from_forgery` on by default | Custom CSRF logic |
| Email previews (dev) | `letter_opener_web` at `/letter_opener`; previews in `test/mailers/previews/` | SMTP config in development |
| Auth controllers | `Public::BaseController`, `Authenticated::BaseController` | New base hierarchies |
| Pagination | Check if `pagy` gem is present; if not, plain SQL offset/limit | Roll-your-own pagination gems |

For each flag: rewrite the criterion to describe the required **behaviour**, not the
implementation. Example:

- ❌ `` `generate_password_reset_token!` stores token using `SecureRandom.urlsafe_base64(32)` ``
- ✅ `User can request a password reset email that contains a secure, expiring link`

---

#### Pass 2 — Acceptance Criteria Quality

Review every `- [ ]` bullet for:

| Problem | Rule | Fix |
|---|---|---|
| Vague language | Every criterion must have a clear pass/fail | Replace "works correctly", "handles errors gracefully", "displays nicely" with specific, observable outcomes |
| Implementation detail | What, not how | Remove method names, column names, gem internals; describe the system behaviour |
| Compound criterion | One thing per bullet | Split bullets joined by "and" or "also" |
| Missing `bin/ci` | Every story needs it | Add `- [ ] \`bin/ci\` passes` if absent |
| Missing UI verification | Any story that changes a view needs it | Add a `- [ ] **[UI story]** …` bullet if absent |
| Vague `[UI story]` bullet | Must describe a specific observable outcome | Rewrite "Verify visually via `bin/dev`" to name the element, text, or redirect to assert — e.g., "Banner with 'Resend' link is visible for unverified users; absent for verified users" |
| Untestable assertion | Must have observable evidence | Rewrite so a test or visual check can prove it |

---

#### Pass 3 — Sequencing Plan

Check whether an **Implementation Sequencing Plan** table exists.

**If the table is missing:** Generate one using the rule:
- migrations → models → mailers/jobs → controllers → views → admin
- Mark dependencies explicitly for every story

**If the table exists:** Validate the dependency order:
- Does any story depend on another that appears later in the table?
- Are migrations done before the models that use their columns?
- Are mailers done before the controllers that call them?
- Are controllers done before views that reference their routes?

Fix any ordering issues in the table.

---

#### Pass 4 — Open Questions Triage

For each Open Question, classify it as:

- **Blocking** — the implementation cannot proceed without an answer (e.g., a
  required decision about how a feature works)
- **Non-blocking** — the implementation can proceed with a sensible default

For non-blocking questions, propose a default answer inline:
```markdown
- Is `pagy` already a dependency?
  <!-- review_prd: Non-blocking. Default: use plain SQL offset/limit; add pagy if already present. -->
```

For blocking questions, surface them clearly in the review output and **stop**.
Do not mark the PRD as ready if a blocking open question is unresolved.

---

#### Pass 5 — Story Size and Completeness

Each story should be completable in one focused agent session. Flag stories that:

- Span multiple unrelated concerns (suggest splitting)
- Have no acceptance criteria (add a note)
- Are missing a description in "As a [user]..." format (add a note)
- Have acceptance criteria that reference a story not yet defined (flag the dependency)

---

### 3. Edit the PRD in place

After all five passes, apply fixes directly to the PRD file:

- Rewrite flagged acceptance criteria
- Add missing `bin/ci` / `[UI story]` bullets
- Add or correct the Implementation Sequencing Plan table
- Add `<!-- review_prd: … -->` inline comments for open question defaults
- Do not delete any story or section — annotate issues inline when a fix requires
  a human decision

---

### 4. Add a Review Summary block to the top of the PRD

Insert a fenced block immediately after the `# PRD:` title:

```markdown
<!-- review_prd summary
Reviewed: YYYY-MM-DD
Status: READY | NEEDS HUMAN INPUT

Fixes applied:
- [list of changes made automatically]

Requires human input before work_prd:
- [list of blocking open questions or unresolvable issues, if any]
-->
```

Set `Status: READY` only if there are no blocking open questions and no
unresolvable issues. Otherwise set `Status: NEEDS HUMAN INPUT`.

---

### 5. Report to the human

After editing the PRD, report:

1. **Status** — READY or NEEDS HUMAN INPUT
2. **Changes made** — brief list of what was fixed automatically
3. **Blocking items** — any open questions or issues that require a human decision
   before `work_prd` can begin

If status is READY, tell the user they can proceed with `work_prd`.
If status is NEEDS HUMAN INPUT, list exactly what decisions are needed.

---

## What review_prd does NOT do

- Does not write application code
- Does not run `bin/ci`
- Does not implement any story or acceptance criterion
- Does not delete stories or sections (only annotates)
- Does not rewrite the PRD's goals, non-goals, or functional requirements
  (only acceptance criteria and the sequencing plan)

---

## Checklist

- [ ] All five passes completed
- [ ] Rails compatibility issues rewritten as behaviour criteria
- [ ] Vague/compound/implementation-detail criteria fixed
- [ ] Implementation Sequencing Plan present and dependency order verified
- [ ] Open questions classified as blocking or non-blocking; defaults added
- [ ] Story size issues flagged
- [ ] Review summary block added to PRD
- [ ] Status reported to human (READY or NEEDS HUMAN INPUT)
```
