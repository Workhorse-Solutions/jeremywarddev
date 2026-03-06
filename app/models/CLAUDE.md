# Models — RailsFoundry

## Multitenancy (non-negotiable)

Every domain model belongs to an `Account`. Unscoped queries that cross account
boundaries are a critical security violation.

- Always add `belongs_to :account` as the first association.
- Never use `default_scope` — scope explicitly in controllers and queries.
- Use `Current.account` (set by `Authenticated::BaseController`) in request context.
- Tenant isolation test is mandatory — see the `add_model` skill.

```ruby
class Widget < ApplicationRecord
  belongs_to :account
  # ...
end

# In controllers/queries — always scope to current account
Current.account.widgets.find(params[:id])
```

## Adding a model

Follow the `add_model` skill (`.claude/skills/add_model/SKILL.md`). It covers
migration conventions, null constraints, fixture setup, and required tests.

## Existing models

| Model | Purpose |
|---|---|
| `User` | Individual with `has_secure_password`; belongs to many accounts |
| `Account` | Tenant root; all domain data scopes here |
| `AccountUser` | Join table; roles: `owner`, `admin`, `member` |
| `Current` | `ActiveSupport::CurrentAttributes` — holds `user` and `account` per request |
