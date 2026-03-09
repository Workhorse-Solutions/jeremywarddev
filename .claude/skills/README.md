# Skills

Skills are reusable, versioned agent workflows that live alongside the application code.

They describe how to perform common, repeatable tasks **in this specific repository**.

Skills evolve with the project and serve as executable knowledge — no external knowledge base required.

---

## What Is a Skill?

A Skill is a Markdown file that contains:

1. **Goal** — What the task accomplishes.
2. **Context** — How this repository approaches the concern.
3. **Steps** — Concrete, repo-specific instructions.
4. **Verify** — How to confirm correctness (including `bin/ci`).

Skills must reference actual files, conventions, and patterns used in this repo.
Avoid generic Rails advice.

---

## When to Use a Skill

If a Skill exists for the requested task:

- Prefer following the Skill over inventing a new approach.
- Keep changes consistent with the documented workflow.
- Update the Skill if improvements are discovered.

Skills help maintain consistency and prevent architectural drift.

---

## Available Skills

| Skill | Invoke | Description |
|---|---|---|
| [`commit/SKILL.md`](commit/SKILL.md) | `/commit` | Format and write git commits — type prefixes, title rules, body criteria |
| [`prd/SKILL.md`](prd/SKILL.md) | `/prd` | Generate a Product Requirements Document for a new feature |
| [`review_prd/SKILL.md`](review_prd/SKILL.md) | `/review_prd` | Review a PRD for Rails compatibility, sequencing correctness, and criteria quality before implementation |
| [`work_prd/SKILL.md`](work_prd/SKILL.md) | `/work_prd` | Implement a PRD story by story — one commit per story, CI green before each commit |
| [`controller/SKILL.md`](controller/SKILL.md) | `/controller` | Scaffold a controller into the correct namespace with layout, routes, and views |
| [`component/SKILL.md`](component/SKILL.md) | `/component` | Scaffold a UI:: ViewComponent with template, i18n, and tests |
| [`form/SKILL.md`](form/SKILL.md) | `/form` | Scaffold a form object (ActiveModel::Model) with validations, `#save`, and tests |
| [`add_model/SKILL.md`](add_model/SKILL.md) | `/add_model` | Scaffold an Account-scoped model with migration, fixture, and tenant-isolation tests |
| [`add_migration/SKILL.md`](add_migration/SKILL.md) | `/add_migration` | Generate and apply a safe migration with null constraints, foreign keys, and correct index syntax |
| [`system_test/SKILL.md`](system_test/SKILL.md) | `/system_test` | Scaffold a system test for a `[UI story]` criterion — rack_test by default, headless Chrome for JS/Turbo/Stimulus |
| [`scaffold/SKILL.md`](scaffold/SKILL.md) | `/scaffold` | Generate a complete Account-scoped CRUD resource: model, migration, form object, controller, views, i18n, routes, sidebar, and tests |

---

## Planned Skills

The following skills are planned:

- `skills/add_stimulus_controller`
- `skills/add_stripe_webhook`

Additional skills may be added as the project evolves.

---

## Adding a New Skill

1. Create `.claude/skills/<task_name>/SKILL.md`
2. Add YAML frontmatter with `name` and `description`.
3. Follow the required format:
   **Goal → Context → Steps → Verify**
4. Reference concrete file paths and conventions from this repo.
5. Ensure verification includes running `bin/ci`.
6. Register the skill in the table above.

Keep Skills concise and actionable.
