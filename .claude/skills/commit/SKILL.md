````skill
---
name: commit
description: >
  Format and write git commits for RailsFoundry. Defines type prefixes, title
  rules, body criteria, and what to avoid. PRD story commits use the story
  identifier as the scope (e.g. feat(UDD-006): …) — see work_prd skill.
---

# Skill: commit

## Goal

Produce clean, consistent, machine-readable git commits that make history
scannable, changelogs generatable, and intent unambiguous — for both human
reviewers and future AI agents working in this repository.

---

## Context

RailsFoundry uses **Conventional Commits** throughout — including PRD story
commits. Story commits use the story identifier as the scope instead of an
area noun (see the `work_prd` skill for commit sequencing rules).

---

## Commit Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Rules

| Part | Rule |
|---|---|
| **Type** | Required. Lowercase. One of the values in the type table below. |
| **Scope** | Optional. Lowercase. Either an area noun (`auth`, `billing`, `sessions`) **or** a PRD story identifier (`UDD-006`). Use the story identifier for all PRD story commits. |
| **Subject** | Required. Imperative mood. No trailing period. 72 characters max. |
| **Body** | Optional but preferred when the *why* is non-obvious. Wrap at 72 chars. |
| **Footer** | Required for breaking changes (`BREAKING CHANGE: <description>`). Optional for issue refs. |

---

## Type Prefixes

| Type | When to use |
|---|---|
| `feat` | A new user-visible feature or behavior |
| `fix` | A bug fix |
| `refactor` | Code change that is neither a feature nor a bug fix |
| `test` | Adding or correcting tests with no production code change |
| `chore` | Dependency updates, Gemfile changes, config tweaks, build setup |
| `docs` | Documentation only (README, PRDs, AGENTS.md, inline comments) |
| `style` | Formatting, whitespace, naming — no logic change |
| `perf` | Performance improvement |
| `security` | Security fix or hardening (prefer over `fix` when security is the primary concern) |
| `revert` | Reverts a previous commit |

---

## Subject Line Rules

1. **Imperative mood** — write as if completing the sentence "This commit will…"
   - ✅ `add email verification to registration flow`
   - ❌ `added email verification` / `adds email verification`
2. **No trailing period.**
3. **72 characters maximum** (including type and scope).
4. **Lowercase** after the colon.
5. **Specific** — describe the change, not the file.
   - ✅ `feat(auth): add forgot-password request form`
   - ❌ `feat: update controllers`

---

## Body Guidelines

Include a body when:

- The *why* behind the change is not obvious from the subject
- A non-trivial technical decision was made (and what alternatives were considered)
- A workaround was necessary (explain the constraint)
- The change has side effects worth calling out

Do **not** use a body to:

- Summarize what files changed (git diff does that)
- Restate the subject line
- Write a wall of text — keep bodies to 3–6 lines

**Separate the subject from the body with a blank line.**

---

## Footer Guidelines

- `BREAKING CHANGE: <description>` — required for any change that breaks
  existing behavior (API, schema, route, config key).
- `Closes #<number>` — reference GitHub issues when applicable.
- Multiple footers are allowed, one per line.

---

## Examples

### Feature, no body needed

```
feat(auth): add forgot-password request form
```

### Bug fix with body

```
fix(sessions): prevent session fixation on login

reset_session was missing before assigning session[:user_id].
Without it, an attacker who planted a session cookie could elevate
privileges after the victim logs in.
```

### Chore

```
chore: add letter_opener_web gem for development email preview
```

### Breaking change

```
feat(users): require email verification before dashboard access

BREAKING CHANGE: users without email_verified_at are now redirected
to a verification prompt. Existing users will need to verify on next
login unless email_verified_at is backfilled.
```

### Docs

```
docs(prd): add auth quality of life PRD
```

### Test only

```
test(password-resets): add expiry edge case coverage to token helpers
```

### PRD story commit

```
feat(UDD-006): add navigation items to user dropdown component
```

```
fix(UDD-007): correct dropdown close behavior when clicking outside
```

The story identifier replaces the area scope. Choose the type that best
describes the story's nature (`feat`, `fix`, `refactor`, etc.). The
`work_prd` skill governs commit sequencing and PRD checkbox updates.

---

## What to Avoid

| Anti-pattern | Why |
|---|---|
| `WIP`, `fix stuff`, `update`, `misc` | Provides no signal |
| `[skip ci]` without explanation | Masks failures |
| Mixing two unrelated changes in one commit | Destroys bisectability |
| Amending a commit that has already been shared/pushed | Rewrites shared history |
| Committing generated files or secrets | See `.gitignore` |
| Past tense: `added X` / `fixed Y` | Breaks imperative mood convention |

---

## Quick Reference Card

```
feat(scope): subject            ← new feature
fix(scope): subject             ← bug fix
refactor(scope): subject        ← no behavior change
test(scope): subject            ← tests only
chore: subject                  ← deps, config, tooling
docs: subject                   ← documentation
security(scope): subject        ← security fix/hardening

feat(ABBREV-NNN): subject       ← PRD story commit (story ID as scope)
fix(ABBREV-NNN): subject        ← PRD story bug fix

BREAKING CHANGE: description    ← footer, breaking changes only
```

---

## Checklist

Before committing:

- [ ] `bin/ci` passes
- [ ] Type prefix is correct
- [ ] Subject is imperative, lowercase, ≤ 72 chars, no trailing period
- [ ] Body present if the *why* is non-obvious
- [ ] `BREAKING CHANGE` footer present if applicable
- [ ] No unrelated changes bundled in
````
