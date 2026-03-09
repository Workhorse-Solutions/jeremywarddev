# CLAUDE.md

**Read [AGENTS.md](AGENTS.md) before doing anything else.**

AGENTS.md is the canonical source of truth for this repository.
If instructions conflict, **AGENTS.md wins**.

This file serves as a lightweight adapter for Claude Code.

---

## Quick Rules

- Verify first — search the repo and docs before assuming an API or pattern.
- Plan for non-trivial tasks (3+ steps) before implementing.
- Minimal diffs — change only what is required.
- Tests are required for new behavior.
- `bin/ci` must pass before marking work complete.
- Be conservative with auth, billing, webhooks, and tenant boundaries.
- Skills and hooks are sourced from the `rails_foundry_cli` gem (`rails_foundry_cli/lib/rails_foundry_cli/`). Run `rails generate rails_foundry_cli:ai_tooling` to install or update them in a consumer app.

## Git Workflow

- **Always pull latest from main before starting work:** `git pull origin main`
- **All feature work must be done in a branch:** `git checkout -b feature/[name]`
- **Branch naming:** `feature/[name]`, `fix/[name]`, `chore/[name]`
- **Never commit directly to main**
- **Push branch and create PR for review**
- **Atomic commits with clear messages**
