---
name: component
description: Scaffold a ViewComponent into the correct namespace with template, i18n, and tests.
---

# Skill: component

## Goal

Add a new ViewComponent following RailsFoundry conventions: generator-first, no hardcoded strings in templates, `private attr_reader` throughout, `bin/ci` green.

---

## Context

- ViewComponent 4.x is installed (`gem "view_component"`).
- Components live in `app/components/` and are always namespaced — never unnamespaced.
- All user-facing strings must come from i18n inputs passed by the caller, or explicit component arguments. No hardcoded text in templates.
- Templates access data via `private attr_reader` methods, never bare `@ivars`.
- The `heroicon` helper is **not** auto-available inside components — call `helpers.heroicon` instead.

---

## Steps

### 1. Choose a namespace

| Namespace | Purpose | Example |
|---|---|---|
| `UI::` | Generic, reusable UI primitives with no domain coupling | `UI::NavListComponent`, `UI::DrawerComponent` |
| Domain namespace | Feature-specific components tightly coupled to one area | `Public::HeroComponent`, `Billing::InvoiceRowComponent` |

**Use `UI::`** when the component is a presentational building block reusable across multiple features or layouts.

**Use a domain namespace** when the component encodes domain concepts (routes, models, locale keys) specific to one area of the app.

> **`UI::` inflection note:** The acronym `UI` is registered in `config/initializers/inflections.rb`, so Rails maps `UI::NavListComponent` → `app/components/ui/nav_list_component.rb` correctly. Other acronym namespaces must be registered there too before generating.

### 2. Generate the component

```
bin/rails generate view_component:component Namespace::MyComponent --no-preview
```

Examples:
```
bin/rails generate view_component:component UI::NavList --no-preview
bin/rails generate view_component:component Public::Hero --no-preview
```

This creates (for `UI::NavList`):
- `app/components/ui/nav_list_component.rb`
- `app/components/ui/nav_list_component.html.erb`
- `test/components/ui/nav_list_component_test.rb`

Never hand-create these files. The generator enforces correct paths.

### 3. Implement the Ruby class

```ruby
# app/components/namespace/my_component.rb
# frozen_string_literal: true

class Namespace::MyComponent < ViewComponent::Base
  def initialize(required_arg:, optional_arg: "default")
    @required_arg = required_arg
    @optional_arg = optional_arg
  end

  private

  attr_reader :required_arg, :optional_arg
end
```

Rules:
- All ivars set in `initialize` must have a corresponding `private attr_reader`.
- Keep logic out of templates — put computed values in private methods on the class.
- If a private method is called from `initialize` (e.g. to compute a default), it may read `@foo` directly inside `initialize` before the reader is available. Prefer readers everywhere else.

### 4. Implement the template

```erb
<%# app/components/namespace/my_component.html.erb %>
<div class="...">
  <%= required_arg %>
</div>
```

Rules:
- No `@` sigils — use reader methods only.
- No hardcoded user-facing strings ("Submit", "Cancel", aria labels, etc.). Receive them as arguments.
- To call Rails view helpers that are not auto-available in components, prefix with `helpers.`:
  ```erb
  <%= helpers.heroicon "bars-3" %>
  ```
- To yield a block from the caller, use `<%= content %>`.

### 5. Add i18n keys

The caller translates; the component receives strings as arguments. Add keys to `config/locales/en.yml` at the call site, not inside the component.

Locale key structure follows the caller's context:
```yaml
en:
  public:
    layout:
      header:
        my_label: "My Label"
```

### 6. Integrate at the call site

Pass all translated strings from the caller:

```erb
<%= render Namespace::MyComponent.new(
  label: t("public.layout.header.my_label"),
  href: root_path
) %>
```

For a component that yields content:

```erb
<%= render Namespace::MyComponent.new(...) do %>
  <p>Side panel content here</p>
<% end %>
```

### 7. Write component tests

```ruby
# test/components/namespace/my_component_test.rb
# frozen_string_literal: true

require "test_helper"

class Namespace::MyComponentTest < ViewComponent::TestCase
  def test_renders_required_arg
    render_inline(Namespace::MyComponent.new(required_arg: "Hello"))
    assert_selector "div", text: "Hello"
  end

  def test_renders_yielded_content
    result = render_inline(Namespace::MyComponent.new(required_arg: "x").with_content("<p>Body</p>"))
    assert_includes result.to_html, "Body"
  end
end
```

Test patterns:
- Use `assert_selector` (Capybara CSS) for DOM structure and text assertions.
- Use `render_inline(...).to_html` with `assert_includes` for class strings that are not valid CSS selectors in isolation (e.g. `"w-full"` inside a multi-class attribute).
- Use `.with_content(...)` to test yielded blocks — do **not** pass a block directly to `render_inline`.
- Never assert on hardcoded user-facing strings from i18n — use `I18n.t(...)` in integration tests.

---

## Composing components

When one component renders another, pass readers as arguments:

```erb
<%= render UI::NavListComponent.new(items: nav_items, orientation: :horizontal) %>
```

The child component is responsible only for its own markup. The parent assembles the composition.

---

## Common mistakes to avoid

| Mistake | Correct approach |
|---|---|
| `<%= @foo %>` in template | `<%= foo %>` via `private attr_reader :foo` |
| `<%= heroicon "bars-3" %>` | `<%= helpers.heroicon "bars-3" %>` |
| Hardcoded string in template | Accept as an argument; caller uses `t(...)` |
| Hand-creating component files | Use `bin/rails generate view_component:component Namespace::Name` |
| Using `UI::` for a domain-specific component | Use a domain namespace (`Public::`, `Billing::`, etc.) |
| Unregistered acronym namespace | Register in `config/initializers/inflections.rb` before generating |
| `render_inline(...) { "content" }` to test blocks | Use `.with_content("content")` |
| `assert_selector "ul.foo.bar.baz"` for computed multi-class strings | Use `assert_includes result.to_html, "baz"` |

---

## Verify

```
bin/ci
```

CI must be green before the task is complete.
