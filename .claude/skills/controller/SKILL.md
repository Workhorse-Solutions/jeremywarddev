---
name: controller
description: Scaffold a controller into the correct RailsFoundry namespace (Public or Authenticated) with proper inheritance, layout, routes, and views.
---

# Skill: controller

## Goal

Add a new controller to RailsFoundry following the enforced namespace → layout contract.
Every controller belongs to exactly one namespace. No exceptions.

---

## Namespace → Layout Contract

| Namespace | Base class | Layout | Authenticated? |
|---|---|---|---|
| `Public::*` | `Public::BaseController` | `"public"` | No |
| `Authenticated::*` | `Authenticated::BaseController` | `"authenticated"` | Yes (via `require_authentication!`) |

This mapping is defined by the base controllers and must never be overridden in child controllers.
Do **not** call `layout` in a child controller. Inherit it.

---

## When to create a new controller vs a new action

**New action** — the subject belongs to an existing controller's resource domain.
Example: adding `Authenticated::DashboardController#index` when `show` already exists.

**New controller** — the subject is a distinct resource or concern.
Example: adding `Authenticated::SettingsController` for user settings.

---

## Steps

### 1. Determine namespace

- Unauthenticated, marketing, or informational pages → `Public`
- Anything behind a login or requiring a session → `Authenticated`

### 2. Create the controller file

**Public example:**
```ruby
# app/controllers/public/widgets_controller.rb
class Public::WidgetsController < Public::BaseController
  def index
  end
end
```

**Authenticated example:**
```ruby
# app/controllers/authenticated/widgets_controller.rb
class Authenticated::WidgetsController < Authenticated::BaseController
  def index
  end
end
```

Rules:
- Inherit from the correct base controller. Never from `ApplicationController` directly.
- Keep controllers thin — no business logic, no queries beyond `find`/`where`.
- One controller per resource. Do not mix namespaces.

### 3. Create the view directory and template

```
app/views/public/widgets/index.html.erb          # for Public
app/views/authenticated/widgets/index.html.erb   # for Authenticated
```

#### View rules

- **No hardcoded strings** — all user-facing text must use `t()` / `t(".key")`. Add keys to the appropriate file under `config/locales/`.
- **Use existing UI components** — wrap page content in `UI::SectionComponent` and `UI::CardComponent` where appropriate. Check `app/components/ui/` for available components.
- **Use form components** — for any form, use `Form::ControlComponent` + `Form::InputComponent` instead of raw Rails form helpers (`f.label`, `f.text_field`, etc.). This ensures consistent styling and inline error display.
- **Use form objects** — when a form doesn't map 1:1 to a single model, create a form object (see `/form` skill) and pass it via `model:` to `form_with`.

#### Minimal starting template

```erb
<% content_for :title, t("public.widgets.index.title") %>

<%= render UI::SectionComponent.new do %>
  <h1 class="text-3xl font-bold mb-4"><%= t("public.widgets.index.title") %></h1>
<% end %>
```

#### Form view template

```erb
<%= form_with model: @form, url: target_path, scope: :widget, class: "space-y-4" do |f| %>
  <%= render Form::ControlComponent.new(form: f, attribute: :name) do |field| %>
    <% field.with_input do %>
      <%= render Form::InputComponent.new(form: f, attribute: :name, type: :text) %>
    <% end %>
  <% end %>

  <div class="card-actions">
    <%= f.submit t(".submit"), class: "btn btn-primary w-full" %>
  </div>
<% end %>
```

### 4. Add routes

Routes use `scope module:` to keep URLs clean (no namespace prefix in the URL).

```ruby
# config/routes.rb

scope module: :public do
  get "/widgets", to: "widgets#index", as: :widgets
end

# or for Authenticated:

scope module: :authenticated do
  get "/widgets", to: "widgets#index", as: :widgets
end
```

Do **not** use `namespace :public` or `namespace :authenticated` — that adds the namespace prefix to URLs.

### 5. Add a navigation link (if user-facing)

- **Public layout** → `app/views/layouts/public.html.erb`
- **Authenticated layout** → `app/views/layouts/authenticated.html.erb`

### 6. Write integration tests

```ruby
# test/integration/widgets_test.rb
require "test_helper"

class WidgetsTest < ActionDispatch::IntegrationTest
  test "GET /widgets returns 200" do
    get widgets_path
    assert_response :ok
  end
end
```

For `Authenticated::` controllers, stub or perform authentication before the request once auth is implemented.

---

## Verify

```
bin/ci
```

CI must be green before the task is complete.

---

## Common mistakes to avoid

| Mistake | Correct approach |
|---|---|
| `layout "public"` in a child controller | Remove it — inherited from `Public::BaseController` |
| `class WidgetsController < ApplicationController` | Use namespace base: `Public::BaseController` or `Authenticated::BaseController` |
| `namespace :authenticated do ... end` in routes | Use `scope module: :authenticated do ... end` |
| Authenticated controller without auth enforcement | Always inherit from `Authenticated::BaseController` |
| Putting business logic in controller | Move to model, service, or form object |
| Hardcoded strings in views | Use `t()` — add keys to `config/locales/` |
| Raw form helpers (`f.label`, `f.text_field`) | Use `Form::ControlComponent` + `Form::InputComponent` |
| `form_with scope:` without `model:` | Pass a form object via `model:` for inline error support |
