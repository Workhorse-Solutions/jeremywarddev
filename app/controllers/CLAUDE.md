# Controllers — RailsFoundry

## Namespace structure

| Namespace | Base class | Layout | Auth |
|---|---|---|---|
| `Public::` | `Public::BaseController` | `public` | None |
| `Authenticated::` | `Authenticated::BaseController` | `authenticated` | Required |

**Never inherit directly from `ApplicationController`** for feature controllers.
Use the appropriate namespace base class.

```ruby
# Public (marketing, login, registration)
class Public::PagesController < Public::BaseController
  def home; end
end

# Authenticated (behind login)
class Authenticated::WidgetsController < Authenticated::BaseController
  def index
    @widgets = Current.account.widgets.all
  end
end
```

## Authentication

`Authenticated::BaseController` sets `Current.user` and `Current.account` via
`before_action :authenticate!`. After that action runs, both are guaranteed
non-nil — no additional nil checks needed.

## Scoping

All queries in `Authenticated::` controllers **must** scope through
`Current.account`. Never query a domain model without an account scope.

## Adding a controller

Follow the `controller` skill (`.claude/skills/controller/SKILL.md`).
