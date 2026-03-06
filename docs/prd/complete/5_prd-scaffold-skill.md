# PRD: Scaffold/CRUD Skill

## Prerequisites

- **PRD 1 (AccountScoped Concern)** must be completed first. The scaffold generates models with `include AccountScoped`.

## Introduction

Create a new AI skill (`scaffold`) that generates a complete Account-scoped CRUD
resource: model, migration, controller, views, form object, i18n, and tests.
This combines and extends the existing `add_model`, `controller`, `form`, and
`component` skills into a single orchestrated workflow.

This is a **CLI gem tooling** item — it's an AI skill, not a Rails generator.

## Goals

- Provide a single skill invocation to scaffold a complete CRUD resource
- Follow all RailsFoundry conventions (AccountScoped, Authenticated namespace, i18n, ViewComponents)
- Generate tests for every layer (model, form, controller integration, system)
- Ensure `bin/ci` passes after scaffold completion
- Reuse existing skills internally where possible

## User Stories

### SCF-001: Create scaffold skill definition

**Description:** As a developer, I want a `/scaffold` skill so that I can generate a complete CRUD resource by describing the model.

**Acceptance Criteria:**
- [x] Skill file exists at `.claude/skills/scaffold/SKILL.md` (canonical source in gem)
- [x] Skill accepts a resource name and field definitions (e.g., `/scaffold Project name:string description:text status:string`)
- [x] Skill document defines the complete generation workflow covering: model, migration, form object, controller, views, i18n, routes, sidebar entry, and tests
- [x] Skill is listed in the skills README
- [x] `bin/ci` passes

### SCF-002: Model and migration generation

**Description:** As a developer using the scaffold skill, I want the model layer generated with AccountScoped concern and proper migration.

**Acceptance Criteria:**
- [x] Skill generates a model with `include AccountScoped`
- [x] Migration includes `account_id` foreign key and all specified fields
- [x] Migration follows RailsFoundry conventions (null constraints, indexes)
- [x] Model includes validations for required fields
- [x] Fixtures are generated for testing
- [x] Model tests verify associations, validations, and account scoping
- [x] `bin/ci` passes

### SCF-003: Controller and routes generation

**Description:** As a developer using the scaffold skill, I want an Authenticated controller with standard CRUD actions.

**Acceptance Criteria:**
- [x] Skill generates `Authenticated::<Resource>Controller` inheriting from `Authenticated::BaseController`
- [x] Controller has `index`, `show`, `new`, `create`, `edit`, `update`, `destroy` actions
- [x] All queries are scoped to `Current.account`
- [x] Routes are injected into the authenticated scope in `config/routes.rb`
- [x] Controller uses a form object for create/update
- [x] Integration tests verify all CRUD actions with authentication
- [x] Integration tests verify account scoping (can't access other account's records)
- [x] `bin/ci` passes

### SCF-004: Form object generation

**Description:** As a developer using the scaffold skill, I want a form object generated for the resource.

**Acceptance Criteria:**
- [x] Skill generates a form object at `app/forms/<resource>_form.rb`
- [x] Form object includes validations matching the model
- [x] Form object handles both create and update operations
- [x] Form object tests are generated
- [x] `bin/ci` passes

### SCF-005: Views and i18n generation

**Description:** As a developer using the scaffold skill, I want views generated with proper i18n and component usage.

**Acceptance Criteria:**
- [x] Skill generates views for index, show, new, edit, and form partial
- [x] Views use existing UI components (`UI::CardComponent`, `UI::Authenticated::PageHeaderComponent`, `RailsFoundry::TableComponent`)
- [x] Views use `Form::ControlComponent` and `Form::InputComponent` for form fields
- [x] All user-facing text uses i18n keys
- [x] i18n locale file is generated with all required keys
- [x] System tests verify the full user flow (create, view, edit, delete)
- [x] `bin/ci` passes
- [x] **[UI story]** System test: `test/system/authenticated/<resources>_test.rb`

### SCF-006: Sidebar navigation integration

**Description:** As a developer using the scaffold skill, I want the new resource added to the sidebar navigation.

**Acceptance Criteria:**
- [x] Skill edits `app/views/layouts/authenticated.html.erb` to add the resource to the `nav_sections` array
- [x] Navigation item uses the correct icon and i18n key
- [x] Skill prompts the developer for the preferred sidebar section and icon
- [x] `bin/ci` passes
- [x] **[UI story]** System test: `test/integration/sidebar_navigation_test.rb`

## Functional Requirements

- FR-1: Skill accepts resource name and field definitions via arguments
- FR-2: Generates AccountScoped model with migration
- FR-3: Generates Authenticated controller with all CRUD actions
- FR-4: Generates form object for create/update
- FR-5: Generates ERB views using existing ViewComponents
- FR-6: Generates i18n locale file
- FR-7: Generates comprehensive tests (model, form, integration, system) — distributed per-story
- FR-8: Injects routes into authenticated namespace
- FR-9: Edits the authenticated layout to add sidebar navigation entry
- FR-10: Runs `bin/ci` as final verification

## Non-Goals

- No API controller generation (use the API namespace generator separately)
- No admin controller generation
- No nested resource support (simple top-level resources only)
- No file upload/attachment handling
- No search or filtering beyond basic pagination
- No Turbo Stream responses (standard HTML request/response)
- No `references` field support — keep to simple field types initially
- No ViewComponent generation for resource cards — use inline ERB matching existing team page patterns
- No `--skip-views` or `--skip-tests` flags — users can ask the agent to skip steps conversationally

## Design Considerations

- The skill should compose existing skills where possible: `add_model` for the model layer, `form` for the form object, `controller` for the controller scaffold
- Views should match the visual patterns established by the team management pages
- Index views should use `RailsFoundry::TableComponent` with sortable headers

## Technical Considerations

- The skill is an AI workflow (SKILL.md), not a Rails generator — it orchestrates multiple code generation steps
- The skill should be conversational: ask for resource name and fields, confirm the plan, then generate
- Field type mapping: `string` → text input, `text` → textarea, `integer` → number input, `boolean` → checkbox, `date` → date input
- The skill file lives in `rails_foundry_cli/lib/rails_foundry_cli/skills/scaffold/`
- Sidebar navigation is hardcoded in `app/views/layouts/authenticated.html.erb` as an inline `nav_sections` array — the skill edits this file directly

## Success Metrics

- Developer can scaffold a complete CRUD resource in under 2 minutes
- Generated code passes `bin/ci` without manual fixes
- Generated code follows all RailsFoundry conventions

## Implementation Sequencing Plan

| Order | Story | Depends On | Reason |
|---|---|---|---|
| 1 | SCF-001: Skill definition | — | Foundation; defines the workflow |
| 2 | SCF-002: Model + migration (with tests) | SCF-001 | First layer of generation |
| 3 | SCF-004: Form object (with tests) | SCF-002 | Needs model to wrap |
| 4 | SCF-003: Controller + routes (with tests) | SCF-002, SCF-004 | Needs model and form object |
| 5 | SCF-005: Views + i18n (with system tests) | SCF-003 | Needs controller and routes |
| 6 | SCF-006: Sidebar navigation | SCF-005 | Needs views and routes in place |
