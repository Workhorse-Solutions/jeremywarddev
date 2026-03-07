````skill
---
name: work_prd
description: >
  Implement a PRD story by story. One commit per story. Commit messages use
  Conventional Commits with the story identifier as scope (e.g. feat(UDD-006)).
  bin/ci must pass before each commit. Never implement ahead of the sequencing plan.
---

# Skill: work_prd

## Goal

Fully implement a PRD by working through its stories in sequence — one story,
one commit, CI green — until every acceptance criterion is checked.

---

## Context

- PRDs live in `docs/prd/prd-<feature-name>.md`.
- Every PRD should have been reviewed by `review_prd` before implementation begins.
  If the PRD does not contain a `<!-- review_prd summary … -->` block, run
  `review_prd` first unless the human explicitly waives it.
- Every PRD contains an **Implementation Sequencing Plan** table that defines
  the mandatory order of stories.
- `bin/ci` runs Brakeman, Bundler Audit, RuboCop, and the full test suite.
  A story is not done until `bin/ci` passes cleanly.
- Commits are recorded in the repository. They must be clean, minimal, and
  reference the story that drove them.

---

## Steps

### 1. Read the entire PRD first

Before touching any code:

- Read the full PRD from `docs/prd/`.
- Identify the **Implementation Sequencing Plan** table — this is the authoritative
  story order. Do **not** work stories in document order unless no sequencing
  plan exists.
- Note all Non-Goals. Any implementation that crosses a Non-Goal boundary is
  out of scope, regardless of what seems natural or helpful.
- Note all Open Questions. If an open question blocks a story, surface it before
  starting that story (see Blockers below).

---

### 2. For each story in sequencing order, follow this loop

#### a. Read the story

- Read the **Description** and every **Acceptance Criteria** item.
- Understand what "done" means before writing a line of code.

#### b. Implement

- Write code and tests together — never code-first, tests-later.
- Make **minimal diffs**. Only change what the acceptance criteria requires.
- Follow all existing RailsFoundry patterns: namespace conventions, thin
  controllers, service objects for business logic, `bin/rails generate` for
  migrations and components.
- Do not implement anything not required by the current story's acceptance
  criteria. No scope creep, even if it "seems obvious".
- **For every `[UI story]` criterion:** use the `system_test` skill to scaffold
  the system test. The test must assert the specific observable outcome described
  in the criterion (element presence, flash text, redirect, etc.). When the test
  passes, update the PRD bullet to reference the test file:
  `- [x] **[UI story]** System test: \`test/system/…\``

#### c. Run `bin/ci`

```bash
bin/ci
```

- If `bin/ci` fails: fix the failures. Do not commit until `bin/ci` is green.
- If a failure is in code you did not touch, note it and continue — but do not
  mask it.

#### d. Update the PRD

Before committing, mark the story's acceptance criteria as checked in the PRD
file:

- Change `- [ ]` to `- [x]` for every acceptance criterion that has been met.
- If a criterion was intentionally deferred (see Blockers), leave it unchecked
  and add a note inline: `- [ ] <!-- deferred: reason -->`.
- The PRD update is staged and included in the same commit as the story code.
  Never commit code without the corresponding PRD checkbox update.

#### e. Commit

Once `bin/ci` passes and the PRD is updated:

```bash
git add -A
git commit -m "feat(ABBREV-NNN): story subject"
```

**Commit message format** — Conventional Commits with the story identifier as scope:

```
feat(TSF-001): create database schema migrations
feat(TSF-002): implement User, Account, AccountUser models
fix(TSF-003): correct account scoping on user queries
```

Rules:
- Use the type that best describes the story (`feat`, `fix`, `refactor`, etc.).
- The scope is the story identifier exactly as it appears in the PRD (e.g. `TSF-001`).
- The subject is the story title in imperative mood, lowercase.
- No body text required unless a decision needs documenting.
- One commit per story. Do not batch multiple stories into one commit.
- Do not amend across story boundaries.
- For all non-story commits (hotfixes, tooling changes, etc.), follow the `commit` skill.

---

### 3. Blockers

If a story cannot be started because:

- An upstream story failed and left the codebase broken
- An **Open Question** in the PRD blocks a technical decision
- A dependency (gem, service, external API) does not exist

**Do not skip the story and continue.** Instead:

1. Stop.
2. Report the blocker clearly: which story is blocked, why, and what is needed
   to unblock.
3. Wait for human input before proceeding.

---

### 4. After the final story

- Confirm all acceptance criteria in the PRD are checked.
- Run `bin/ci` one final time to confirm the full suite is green.
- Move the completed PRD to `docs/prd/complete/`:

  ```bash
  mv docs/prd/prd-<feature-name>.md docs/prd/complete/prd-<feature-name>.md
  git add -A
  git commit -m "chore(ABBREV): mark PRD complete"
  ```

- Report completion: list every story committed, the final `bin/ci` status, and
  any criteria that remain unchecked with reasons.

---

## Commit Message Reference

| Pattern | Example |
|---|---|
| Story commit (includes PRD checkbox update) | `feat(TSF-001): create database schema migrations` |
| PRD archival commit | `chore(TSF): mark PRD complete` |
| Bug fix within a story | `fix(TSF-002): correct email uniqueness validation` |
| Non-story hotfix | `fix(auth): resolve session fixation on login` |

Never use:
- `WIP`, `fixup`, `temp`, or other non-descriptive messages
- Commits that mix two story identifiers
- Commits with no story identifier for story work

---

## Checklist (per story)

- [ ] Full story read before implementation started
- [ ] Only acceptance criteria scope implemented (no extras)
- [ ] Tests written alongside code
- [ ] `bin/ci` passes
- [ ] PRD acceptance criteria checkboxes updated (`- [x]`) before committing
- [ ] Committed with `<type>(ABBREV-NNN): subject` (includes PRD update)

---

## Checklist (end of PRD)

- [ ] All stories in sequencing order completed
- [ ] All acceptance criteria in PRD are checked (or noted as deferred)
- [ ] Final `bin/ci` passes
- [ ] PRD moved to `docs/prd/complete/` and committed
- [ ] Completion report delivered to human
````
