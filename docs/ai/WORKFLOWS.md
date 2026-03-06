# Agent Workflows

RailsFoundry favors calm, disciplined development.
These workflows apply to both humans and AI agents.

---

## Plan First (Non-Trivial Work)

For tasks involving 3+ steps, architectural decisions, or new features:

1. Outline a short plan.
2. Identify files to be changed.
3. Implement minimal diffs.
4. Add or update tests.
5. Run `bin/ci` before declaring the task complete.

Avoid jumping directly to implementation for complex changes.

---

## Verify First

Before using an unfamiliar API or pattern:

1. Search the repo:
   `grep -r "ClassName\|method_name" app/`
2. Read relevant Rails/gem documentation.
3. Check existing tests for usage examples.
4. Only then implement — matching established patterns.

Do not guess method signatures or assume gem behavior.

---

## CI is Final Authority

Before marking work complete:

- Run `bin/ci`
- Ensure it exits successfully
- Fix failures before proceeding

A change is not complete unless CI passes.

---

## PR Size & Tests

- Keep changes small and focused.
- Each behavior change must include tests.
- Prefer unit tests for domain logic.
- Use integration/system tests for critical flows (auth, billing, multitenancy).
- Avoid large refactors unless explicitly requested.

---

## Multitenancy Guardrails

RailsFoundry is Account-scoped.

- Always scope domain models to the current account.
- Never expose cross-account data.
- Avoid global queries unless explicitly required.
- Add tests to validate access boundaries.

Tenant isolation is non-negotiable.

---

## Security-Sensitive Areas

Extra care is required in these areas. When in doubt, stop and reassess.

| Area | Rules |
|---|---|
| **Authentication** | Never bypass authentication or authorization checks. Always test access control. |
| **Billing / Stripe** | Never expose secret keys. Validate webhook signatures. Use Stripe test mode in development. |
| **Webhooks** | Verify signatures before processing. Ensure idempotency of side effects. |
| **Tokens / secrets** | No secrets in source code. Use credentials or env vars. Never log tokens. |
| **Mass assignment** | Always use strong parameters. Never `permit!` in production code. |

---

## Continuous Improvement (Lessons Loop)

When a human corrects an avoidable mistake:

1. Apply the correction.
2. Add a short entry to `docs/ai/LESSONS.md`:
   - Mistake
   - New rule
   - Example

RailsFoundry improves over time through captured lessons.

---

## PRD Skill — Planning Features with Claude Code

A Claude Code project skill for generating PRDs is available at
`.claude/skills/prd/SKILL.md`.

**Invoke it with:** `/prd`

**What it does:**
1. Asks 3–5 clarifying questions with lettered options.
2. Generates a structured PRD (Introduction → Goals → User Stories →
   Functional Requirements → Non-Goals → Technical Considerations →
   Success Metrics → Open Questions).
3. Saves the file to `docs/prd/prd-<feature-name>.md`.

**Important:** The skill produces the PRD only — it does not start
implementing code.

Every story's acceptance criteria includes `bin/ci` passes, and UI stories
include `bin/dev` verification.

---

## review_prd Skill — Reviewing a PRD Before Implementation

A skill for validating a PRD before any code is written, available at
`.claude/skills/review_prd/SKILL.md`.

**Invoke it with:** `/review_prd`

**What it does:**
1. Checks acceptance criteria for Rails compatibility (flags reinvented-wheel patterns).
2. Verifies or generates the **Implementation Sequencing Plan**.
3. Triages open questions as blocking or non-blocking.
4. Flags vague, untestable, or implementation-prescriptive criteria.
5. Outputs a `REVIEW` block in the PRD with a `READY` / `NEEDS WORK` / `BLOCKED` status.

**Run this between `prd` and `work_prd`:**

```
prd  →  review_prd  →  work_prd
```

---

## work_prd Skill — Implementing a PRD Story by Story

A skill for systematically working through a PRD is available at
`.claude/skills/work_prd/SKILL.md`.

**Invoke it with:** `/work_prd`

**What it does:**
1. Reads the full PRD and the **Implementation Sequencing Plan**.
2. Implements stories in sequencing order — never document order.
3. Runs `bin/ci` before committing each story.
4. Commits with `[ABBREV-NNN] Story title` format (one commit per story).
5. Checks off acceptance criteria in the PRD file after each commit.
6. Stops and surfaces blockers rather than skipping stories.
7. Reports completion with a summary of all commits and any deferred criteria.

**Important:** A story is not done until `bin/ci` passes. A commit is never
made against a failing suite.

---

## Cutting a Release

See [docs/ai/RELEASE.md](RELEASE.md) for the full release process.

**Quick reference:**

```bash
git tag v1.2.3
foundry release v1.2.3 --from-tag v1.2.3
```

The `foundry release` command publishes both the gem repo and the release template repo,
runs CI against the stripped snapshot, and prompts before pushing.
