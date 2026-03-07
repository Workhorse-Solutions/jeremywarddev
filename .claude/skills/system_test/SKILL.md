````skill
---
name: system_test
description: Scaffold a system test for a [UI story] acceptance criterion. Covers rack_test (no JS) and headless Chrome (JS/Turbo/Stimulus) patterns, with sign-in helpers and CI integration.
---

# Skill: system_test

## Goal

Convert a `[UI story]` acceptance criterion into an automated system test that runs
headlessly in CI, replacing the manual "verify visually via `bin/dev`" step.

---

## When to use this skill

Use a system test when you need to assert:

- An element is visible or hidden based on application state (banners, notices)
- A form submission redirects and shows a flash message
- A multi-step flow works end-to-end (submit form → redirect → new page state)
- Turbo navigation, Turbo Frames, or Turbo Streams update the DOM
- A Stimulus controller modifies the page in response to user interaction

**Do NOT use a system test when a controller/integration test is sufficient.** If the
assertion is "route responds with 200 and renders X", use `ActionDispatch::IntegrationTest`.
The rule: controller tests cover HTTP semantics; system tests cover browser-visible behavior.

---

## Driver selection

| Situation | Driver | Speed |
|---|---|---|
| No JS needed (form submit, redirect, element presence) | `:rack_test` | ~50ms/test |
| Turbo navigation or Stimulus required | `:selenium, using: :headless_chrome` | ~500ms–2s/test |

Set the driver **per test class**, not globally. Default to `:rack_test`. Opt into
`:selenium` only when the test genuinely requires it.

---

## One-time setup

### 1. Create the base test case

If `test/system/application_system_test_case.rb` does not exist, create it:

```ruby
# test/system/application_system_test_case.rb
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :rack_test

  # Sign in as a given user by posting to the login endpoint.
  # Requires the sessions fixture and password "password".
  def sign_in_as(user)
    visit login_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_on "Sign in"
  end
end
```

### 2. Enable system tests in CI

In `config/ci.rb`, uncomment the system test step:

```ruby
step "Tests: System", "bin/rails test:system"
```

This runs system tests as a separate CI step after the unit/integration suite.

---

## Writing a system test

### File location

```
test/system/<namespace>/<feature>_test.rb
```

Examples:
- `test/system/public/password_resets_test.rb`
- `test/system/authenticated/email_verification_banner_test.rb`
- `test/system/admin/users_test.rb`

### Class naming

Match the file path. Examples:
- `Public::PasswordResetsSystemTest`
- `Authenticated::EmailVerificationBannerSystemTest`
- `Admin::UsersSystemTest`

### No-JS template (rack_test driver)

```ruby
# test/system/public/password_resets_test.rb
require "test_helper"

class Public::PasswordResetsSystemTest < ApplicationSystemTestCase
  # rack_test is inherited from ApplicationSystemTestCase

  test "submitting forgot password form shows neutral flash" do
    visit forgot_password_path

    fill_in "Email", with: "anyone@example.com"
    click_on "Send reset instructions"

    assert_text "If that email address is registered"
  end

  test "reset password form with mismatched passwords shows error" do
    user = users(:alice)
    token = user.password_reset_token

    visit edit_password_reset_path(token: token)

    fill_in "Password", with: "newpassword"
    fill_in "Password confirmation", with: "different"
    click_on "Reset password"

    assert_text "doesn't match"
    assert_current_path reset_password_path
  end
end
```

### JS-required template (Selenium headless Chrome driver)

Override `driven_by` at the class level:

```ruby
# test/system/authenticated/email_verification_banner_test.rb
require "test_helper"

class Authenticated::EmailVerificationBannerSystemTest < ApplicationSystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "unverified user sees verification banner" do
    sign_in_as users(:alice)  # alice is unverified in fixtures

    assert_selector "[data-testid='email-verification-banner']"
    assert_text "Resend verification email"
  end

  test "verified user does not see verification banner" do
    sign_in_as users(:bob)  # bob is verified in fixtures

    assert_no_selector "[data-testid='email-verification-banner']"
  end
end
```

---

## Fixture requirements

System tests rely on existing fixtures in `test/fixtures/users.yml`.
Check that relevant user states exist (e.g., `email_verified_at: null` vs. a set date).

If a required fixture state is missing, add it to `test/fixtures/users.yml` as part
of this task.

---

## Useful Capybara assertions

| Goal | Assertion |
|---|---|
| Text is on page | `assert_text "Expected text"` |
| Text is absent | `assert_no_text "Unexpected text"` |
| Element is present | `assert_selector "css-selector"` |
| Element is absent | `assert_no_selector "css-selector"` |
| Current URL matches | `assert_current_path path_helper` |
| Flash message present | `assert_selector ".alert", text: "message"` |
| Input has value | `assert_field "Label", with: "value"` |

Use `data-testid` attributes for assertions on UI components to decouple tests from
styling changes. Add the attribute to the component/partial as you write the test.

---

## Screenshots on failure

Capybara + Selenium captures a screenshot automatically on test failure. By default,
screenshots are saved to `tmp/screenshots/`. No extra configuration needed.

For `rack_test` tests, screenshots are not available (no browser). This is expected.

---

## Mapping `[UI story]` criteria to assertions

| `[UI story]` description | Test approach | Driver |
|---|---|---|
| Form renders correctly | `assert_selector "form"`, `assert_field` | `rack_test` |
| Flash message appears | `assert_text "message"` | `rack_test` |
| Redirect to correct page | `assert_current_path` | `rack_test` |
| Banner visible/hidden | `assert_selector` / `assert_no_selector` | `rack_test` |
| Turbo Stream updates DOM | `assert_selector` after action | `:selenium` |
| Stimulus controller toggles | Interact + `assert_selector` | `:selenium` |
| Multi-step form flow | Visit, fill, click, assert each step | `:selenium` |

When the `[UI story]` item is purely aesthetic (layout, color, spacing), a system test
adds limited value. Assert structural presence (element exists, text correct) and
note the visual check as a manual step if needed.

---

## Marking `[UI story]` done

When the system test is written and CI passes, mark the PRD criterion:

```markdown
- [x] **[UI story]** System test: `test/system/public/password_resets_test.rb`
```

Replace "Verify visually via `bin/dev`" with the test file path.

---

## Verify

```
bin/rails test:system
bin/ci
```

Both must pass. `bin/ci` runs system tests as a separate step (once enabled in `config/ci.rb`).

---

## Common mistakes to avoid

| Mistake | Correct approach |
|---|---|
| Using `:selenium` for every test | Default to `:rack_test`; only use `:selenium` when JS is genuinely required |
| Asserting CSS classes directly | Use `data-testid` or text content — styles change, structure doesn't |
| Hardcoding user passwords in tests | Always use `"password"` (the fixture default) |
| Testing controller logic via system test | Controller tests cover HTTP behavior; system tests cover browser-visible behavior |
| One giant system test file per feature | Split by namespace/resource — keep files small and focused |
| Forgetting to enable system tests in ci.rb | Uncomment `step "Tests: System"` in `config/ci.rb` on first system test added |
````
