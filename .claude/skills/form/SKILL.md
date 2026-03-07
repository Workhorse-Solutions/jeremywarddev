---
name: form
description: Scaffold a form object (ActiveModel::Model) with validations, #save, and tests.
---

# Skill: form

## Goal

Create a form object in `app/forms/` that encapsulates validation and persistence for a multi-model or non-standard form. Form objects give `form_with` a proper `model:` to bind to, enabling inline field errors via `Form::ControlComponent`.

---

## Context

RailsFoundry uses form objects when:

- A form spans multiple ActiveRecord models (e.g., registration creates User + Account + AccountUser)
- A form doesn't map 1:1 to a model (e.g., login, search, import)
- A controller action needs validations that differ from the underlying model

Form objects live in `app/forms/` and follow the `<Name>Form` naming convention.

**Reference implementation:** `app/forms/registration_form.rb`

---

## Steps

### 1. Create the form class

```ruby
# app/forms/<name>_form.rb
class <Name>Form
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :field_one, :string
  attribute :field_two, :string

  validates :field_one, presence: true

  attr_reader :created_record  # expose created records for post-save access

  def save
    return false unless valid?

    # Wrap multi-model creation in a transaction
    ActiveRecord::Base.transaction do
      @created_record = Model.create!(...)
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.each do |error|
      errors.add(error.attribute, error.message)
    end
    false
  end
end
```

Rules:

- Include `ActiveModel::Model` and `ActiveModel::Attributes` — this provides `form_with model:` compatibility.
- Declare all form fields as `attribute` with a type.
- Add validations that match the user-facing form requirements.
- Implement `#save` returning `true`/`false` (ActiveRecord convention).
- Wrap multi-record creation in `ActiveRecord::Base.transaction`.
- Rescue `ActiveRecord::RecordInvalid` and merge errors onto the form object.
- Use `attr_reader` to expose created records (e.g., `user`, `account`).

### 2. Wire up the controller

```ruby
def new
  @form = <Name>Form.new
end

def create
  @form = <Name>Form.new(form_params)

  if @form.save
    redirect_to success_path
  else
    render :new, status: :unprocessable_entity
  end
end

private

def form_params
  params.require(:<name>).permit(:field_one, :field_two)
end
```

The `scope:` in `form_with` should match the `params.require` key.

### 3. Use in the view

```erb
<%= form_with model: @form, url: target_path, scope: :<name>, class: "space-y-4" do |f| %>
  <%= render Form::ControlComponent.new(form: f, attribute: :field_one) do |field| %>
    <% field.with_input do %>
      <%= render Form::InputComponent.new(form: f, attribute: :field_one, type: :text) %>
    <% end %>
  <% end %>

  <div class="card-actions">
    <%= f.submit t(".submit"), class: "btn btn-primary w-full" %>
  </div>
<% end %>
```

Passing `model:` ensures `form.object` is the form instance, so `Form::ControlComponent` and `Form::InputComponent` can display inline errors automatically.

### 4. Write tests

```ruby
# test/forms/<name>_form_test.rb
require "test_helper"

class <Name>FormTest < ActiveSupport::TestCase
  def valid_params
    { field_one: "value", field_two: "value" }
  end

  # Validation tests
  test "valid with all required attributes" do
    assert <Name>Form.new(valid_params).valid?
  end

  test "invalid without field_one" do
    form = <Name>Form.new(valid_params.merge(field_one: ""))
    assert_not form.valid?
    assert form.errors[:field_one].any?
  end

  # Save tests
  test "save creates records on success" do
    form = <Name>Form.new(valid_params)
    assert_difference "Model.count", 1 do
      assert form.save
    end
  end

  test "save returns false and does not persist on failure" do
    assert_no_difference "Model.count" do
      <Name>Form.new(valid_params.merge(field_one: "")).save
    end
  end
end
```

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
| Using `scope:` without `model:` in `form_with` | Always pass `model:` so `form.object` is the form instance |
| Hardcoding strings in the form view | Use `t(".key")` — add keys to the appropriate locale file |
| Not rescuing `ActiveRecord::RecordInvalid` | Always rescue and merge errors for inline display |
| Putting transaction logic in the controller | Keep it in the form's `#save` method |
| Skipping `return false unless valid?` in `#save` | Always validate before attempting persistence |
