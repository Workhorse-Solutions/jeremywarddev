---
name: add_migration
description: >
  Generate and apply a safe database migration following RailsFoundry
  conventions: null constraints, foreign keys, correct index syntax, and
  schema verification.
---

# Skill: add_migration

## Goal

Generate, write, and apply a database migration that follows RailsFoundry
schema conventions — null-safe, with foreign keys, and passing CI.

---

## Context

RailsFoundry uses PostgreSQL 16. Migrations must be safe for production
(no locking issues on large tables, explicit null constraints, foreign keys
on all references). The canonical schema is `db/schema.rb`; never edit it
directly.

A RuboCop rule requires spaces inside array literals:
`[ :col_a, :col_b ]` not `[:col_a, :col_b]` — applies to `add_index` calls.

---

## Steps

### 1. Generate the migration

Use the Rails generator — never write migration files by hand.

**Create a table:**
```bash
bin/rails generate migration CreateWidgets \
  account:references \
  name:string \
  status:string
```

**Add a column:**
```bash
bin/rails generate migration AddPublishedAtToWidgets published_at:datetime
```

**Add a reference:**
```bash
bin/rails generate migration AddAccountToWidgets account:references
```

**Add an index:**
```bash
bin/rails generate migration AddIndexToWidgetsName
```

### 2. Edit the generated file

Open the file in `db/migrate/`. Apply these rules:

#### Null constraints on required columns
```ruby
t.string :name, null: false          # required
t.string :status, null: false, default: "draft"
t.datetime :published_at             # optional — may be null
```

#### References must have foreign_key: true
```ruby
t.references :account, null: false, foreign_key: true
```

#### Indexes: spaces inside brackets (RuboCop enforces this)
```ruby
# Correct
add_index :widgets, [ :account_id, :name ], unique: true

# Wrong — will fail RuboCop
add_index :widgets, [:account_id, :name], unique: true
```

#### Composite unique index pattern
```ruby
add_index :table_name, [ :account_id, :slug ], unique: true
```

#### Adding a column safely (existing table)
For tables that may already have data, provide a default or use a two-step
migration if the column is `null: false`:
```ruby
# Step 1 migration: add nullable
add_column :widgets, :status, :string

# Step 2 migration: backfill then constrain
Widget.update_all(status: "draft")
change_column_null :widgets, :status, false
change_column_default :widgets, :status, "draft"
```

### 3. Run the migration

```bash
bin/rails db:migrate
```

### 4. Verify the schema

Open `db/schema.rb` and confirm:
- New table / column appears correctly
- `null: false` is present where expected
- Index is present

### 5. Update seeds if needed

If the new table or column requires seed data, update `db/seeds.rb` and verify:
```bash
env RAILS_ENV=test bin/rails db:seed:replant
```

### 6. Verify CI

```bash
bin/ci
```

---

## Checklist

- [ ] Migration generated with `bin/rails generate migration`, not hand-written
- [ ] `null: false` on all required columns
- [ ] `foreign_key: true` on all `references`
- [ ] Array index literals use spaces: `[ :a, :b ]`
- [ ] `db/schema.rb` updated and committed
- [ ] Seeds updated if the change requires it
- [ ] `bin/ci` passes
