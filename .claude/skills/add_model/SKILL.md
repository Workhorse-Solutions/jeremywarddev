---
name: add_model
description: >
  Scaffold an Account-scoped ActiveRecord model with migration, associations,
  validations, fixtures, and tests. Enforces multitenancy isolation.
---

# Skill: add_model

## Goal

Add a new domain model that is safely scoped to the current `Account`, with a
migration, validated associations, fixtures, and tests that verify tenant
isolation.

---

## Context

RailsFoundry uses Account-scoped multitenancy. Every domain model (anything
that belongs to a tenant's data) **must** be associated with an `Account` and
all queries **must** be scoped to the current account. Unscoped cross-account
queries are a critical security violation.

`Current.account` holds the current account in request context
(`app/models/current.rb`).

---

## Steps

### 1. Generate the model

```bash
bin/rails generate model ModelName \
  account:references \
  field1:type \
  field2:type
```

- Always include `account:references` as the **first** reference.
- Use `null: false` for required fields in the migration (see Step 2).
- Use `string` for enum-like fields; validate inclusion in the model.

### 2. Review and tighten the migration

Open the generated migration in `db/migrate/` and:

- Add `null: false` to all required columns.
- Add `null: false, foreign_key: true` to all `references` columns (Rails
  generator adds this automatically for `references`; verify it is present).
- Add a composite unique index if needed:
  ```ruby
  add_index :table_name, [ :account_id, :other_field ], unique: true
  ```
- Array literals **must** have spaces inside brackets (RuboCop rule):
  `[ :account_id, :name ]` not `[:account_id, :name]`

### 3. Run the migration

```bash
bin/rails db:migrate
```

Verify `db/schema.rb` reflects the new table.

### 4. Write the model

Open `app/models/model_name.rb`. Required structure:

```ruby
class ModelName < ApplicationRecord
  belongs_to :account

  # Other associations
  # belongs_to :user

  # Validations
  validates :name, presence: true

  # Account-scoped query helper (add when useful)
  scope :for_account, ->(account) { where(account: account) }
end
```

**Do not** add a `default_scope` — use explicit scoping in controllers and
queries instead.

### 5. Add a fixture

Create `test/fixtures/model_names.yml`:

```yaml
one:
  account: acme
  name: Example Record
  # other fields...
```

Always associate fixtures with the `acme` account (the canonical test account).

### 6. Write tests

Create `test/models/model_name_test.rb`:

```ruby
require "test_helper"

class ModelNameTest < ActiveSupport::TestCase
  # Associations
  test "belongs to account" do
    assert_respond_to model_names(:one), :account
  end

  # Validations
  test "valid with required attributes" do
    record = ModelName.new(account: accounts(:acme), name: "Test")
    assert record.valid?
  end

  test "invalid without name" do
    record = ModelName.new(account: accounts(:acme))
    assert_not record.valid?
    assert_includes record.errors[:name], "can't be blank"
  end

  # Tenant isolation — REQUIRED for every account-scoped model
  test "does not expose records from other accounts" do
    other_account = Account.create!(name: "Other", billing_status: "trialing")
    other_record  = ModelName.create!(account: other_account, name: "Private")

    scoped = ModelName.where(account: accounts(:acme))
    assert_not_includes scoped, other_record
  end
end
```

The tenant isolation test is mandatory.

### 7. Verify

```bash
bin/rails test test/models/model_name_test.rb
bin/ci
```

---

## Checklist

- [ ] Migration has `null: false` on required columns
- [ ] Migration uses spaces inside array brackets for indexes
- [ ] Model has `belongs_to :account`
- [ ] No `default_scope` added
- [ ] Fixture uses `acme` account
- [ ] Tests cover: associations, validations, tenant isolation
- [ ] `bin/ci` passes
