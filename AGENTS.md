# AGENTS.md — RailsFoundry

RailsFoundry is an opinionated, AI-native Rails foundation for building production SaaS.

This file is the canonical source of truth for AI agents (Claude Code, Copilot, etc.) working in this repository.
If instructions conflict, **AGENTS.md wins**.

---

## Purpose

RailsFoundry provides:

- A production-ready Rails 8 baseline
- Sensible defaults for auth, multitenancy, and billing
- Guardrails for safe AI-assisted development
- A minimal foundation — not a feature-bloated template

---

## Stack

| Layer | Choice |
|---|---|
| Framework | Rails 8 (Propshaft, import maps) |
| Database | PostgreSQL 16 |
| CSS | Tailwind CSS + DaisyUI |
| JavaScript | Stimulus + Turbo (Hotwire) |
| Background jobs | Solid Queue |
| Deployment | Kamal 2 |
| Payments | Stripe |

See [docs/ai/STACK.md](docs/ai/STACK.md) for configuration locations.

---

## Identity & Collision Safety

RailsFoundry is reused across many apps.

- **Do not rename the internal Ruby module or application class.**
- External identity is configured via:
  - `APP_NAME` (display name)
  - `APP_IDENTIFIER` (machine-safe identifier; must be unique per app)

When modifying cookies, database names, cache keys, or deployment config, use `APP_IDENTIFIER` to prevent collisions.

---

## Dev Mode Detection

The `.railsfoundry-dev` marker file in the repo root indicates this is the RailsFoundry **development repository** (not a consumer app cloned from a release snapshot).

When this file is present:
- `bin/setup` automatically runs `rails generate rails_foundry_cli:demo --force` to install demo content (landing page, pricing page, seed data).
- `bin/setup` then runs `bin/rails db:seed` to populate the database.

Consumer apps cloned from a release snapshot will **not** have this file. The release manifest (`.foundry-release-ignore`) excludes `.railsfoundry-dev` from all release snapshots.

Do **not** delete `.railsfoundry-dev` from the dev repo.

---

## Non-Negotiables

1. **Verify first.** Search the repo and consult docs before implementing uncertain APIs or patterns.
2. **Minimal diffs.** Change only what is required. Avoid unrelated reformatting.
3. **Tests required.** New behavior requires corresponding tests.
4. **Follow existing patterns.** Match structure, naming, and style already in the codebase.
5. **Be conservative with auth, billing, and webhooks.** These areas require extra scrutiny.
6. **`bin/ci` must pass.** Before completing a task, run `bin/ci`. A change is not complete unless CI passes.
7. **Follow the commit skill.** All commits must follow [`.claude/skills/commit/SKILL.md`](.claude/skills/commit/SKILL.md). PRD story commits use `[ABBREV-NNN]` format (see `work_prd` skill).

See [docs/ai/WORKFLOWS.md](docs/ai/WORKFLOWS.md) for details.

---

## Adding Gems

"Minimal diffs" does not mean "never add gems." It means don't add gems opportunistically or without justification.

**The rule:** If a task would benefit from a gem that is not already in the Gemfile, **propose it and confirm with the human before adding it.** One sentence is enough: state the gem, the reason, and any notable alternative.

Once confirmed, add it as part of the story — it is intentional architecture, not scope creep.

**Prefer gems that:**
- Are widely adopted in the Rails ecosystem
- Have a small footprint and no monkey-patching
- Solve a recurring problem rather than a one-off

**Don't add gems that:**
- Duplicate functionality already provided by Rails or an existing dependency
- Introduce a new paradigm inconsistent with the existing stack
- Have not been confirmed by a human for this codebase

---

## Preferred Task Format

For non-trivial tasks (3+ steps or architectural decisions):

1. **Plan** — brief approach and files to change
2. **Files** — list of files created or modified
3. **Changes** — implement minimal diffs
4. **Tests** — add or update tests
5. **Verify steps** — commands or steps to confirm correctness

No task is complete without verification.

---

## Continuous Improvement

When corrected by a human or when an avoidable mistake is discovered:

- Apply the correction.
- Add a short entry to `docs/ai/LESSONS.md` describing:
  - Mistake
  - New rule
  - Example

When a task would have been significantly easier with a reusable skill:

- Note it at the end of the task (don't interrupt flow).
- Add a short entry to `docs/ai/LESSONS.md` describing:
  - Task that exposed the gap
  - What the skill would do
  - Whether it justifies a dedicated skill or is better as a one-off prompt

RailsFoundry improves over time through captured lessons.

---

## Skills

Reusable agent workflows live in [`.claude/skills/`](.claude/skills/README.md), versioned alongside the code.

**Canonical source:** Skills originate from the [`rails_foundry_cli` gem](rails_foundry_cli/lib/rails_foundry_cli/skills/). Consumer apps install them by running `rails generate rails_foundry_cli:ai_tooling`, which copies skill files into the app's `.claude/skills/` directory.

**Override mechanism:** Local edits to `.claude/skills/<name>/SKILL.md` take precedence over the gem-bundled defaults. Re-running the generator will prompt before overwriting any locally modified file. Local overrides should be tracked in git.

---

## Hooks

Automated hooks are configured in [`.claude/settings.json`](.claude/settings.json) and run on every session:

| Hook | Trigger | Action |
|---|---|---|
| `post-write-rubocop` | After any `.rb` file is written or edited | Runs `bin/rubocop --autocorrect` on the file |
| `stop-ci-reminder` | When Claude finishes a response | Reminds agent to run `bin/ci` before completing work |

Hook scripts live in [`.claude/hooks/`](.claude/hooks/). The canonical source for hook scripts is the [`rails_foundry_cli` gem](rails_foundry_cli/lib/rails_foundry_cli/hooks/); they are installed alongside skills via `rails generate rails_foundry_cli:ai_tooling`.

---

## Further Reading

- [docs/ai/STACK.md](docs/ai/STACK.md)
- [docs/ai/WORKFLOWS.md](docs/ai/WORKFLOWS.md)
- [docs/ai/LESSONS.md](docs/ai/LESSONS.md)
- [.claude/skills/README.md](.claude/skills/README.md)
