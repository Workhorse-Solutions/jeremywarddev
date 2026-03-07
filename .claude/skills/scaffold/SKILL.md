---
name: scaffold
description: Generate a complete Account-scoped CRUD resource — model, migration, form object, controller, views, i18n, routes, sidebar, and tests. Composes add_model, form, and controller skills.
---

# Skill: scaffold

## Goal

Generate a complete, production-ready CRUD resource scoped to the current `Account`.
The scaffold orchestrates the `add_model`, `form`, and `controller` skills into a
single, end-to-end workflow that produces passing `bin/ci` output without manual fixes.

---

## Context

RailsFoundry scaffold generates resources following all established conventions:

- **Models** include `AccountScoped` for multitenancy isolation.
- **Controllers** live in the `Authenticated::` namespace, inheriting `Authenticated::BaseController`.
- **Queries** are scoped to `Current.account` — never unscoped.
- **Views** use `RailsFoundry::TableComponent` for index tables, `UI::CardComponent` for forms.
- **Forms** use `Form::ControlComponent` + `Form::InputComponent` — never raw Rails helpers.
- **i18n** — all user-facing strings use `t(".key")` keys. No hardcoded strings in views.
- **Tests** are generated for every layer: model, form object, integration, and system.

The scaffold is **conversational**: confirm the resource name and fields before generating.

---

## Steps

### 0. Gather and confirm inputs

Ask the developer for:

1. **Resource name** — singular, CamelCase (e.g. `Project`, `BlogPost`).
2. **Fields** — list of `name:type` pairs (e.g. `title:string body:text status:string`).

Supported field types:

| Type | HTML input | Notes |
|---|---|---|
| `string` | `text` | Default for short text |
| `text` | `textarea` | Long-form content |
| `integer` | `number` | Numeric fields |
| `boolean` | `checkbox` | True/false flags |
| `date` | `date` | Date picker |

> **Non-goals:** `references` fields, file uploads, and enum types are out of scope.
> Ask the developer to add those manually after scaffolding.

Present a summary and wait for confirmation before generating any code:

```
Scaffold plan for Project:
  Fields: title:string, body:text, status:string
  Files to generate:
    - app/models/project.rb + migration
    - app/forms/project_form.rb
    - app/controllers/authenticated/projects_controller.rb
    - app/views/authenticated/projects/ (index, show, new, edit, _form)
    - config/locales/projects.en.yml
    - Routes: resources :projects (authenticated scope)
    - Sidebar: add to authenticated.html.erb nav_sections
    - Tests: model, form, integration, system

Proceed? (yes / adjust fields)
```

---

### 1. Model and migration

> Full reference: [`add_model/SKILL.md`](../add_model/SKILL.md)

#### 1a. Generate the model

```bash
bin/rails generate model <Resource> account:references <field1:type> <field2:type> ...
```

Example for `Project title:string body:text status:string`:

```bash
bin/rails generate model Project account:references title:string body:text status:string
```

#### 1b. Tighten the migration

Open `db/migrate/<timestamp>_create_<resources>.rb` and apply:

- `null: false` on the `account` reference (Rails generator adds this; verify it is present).
- `foreign_key: true` on the `account` reference (verify it is present).
- `null: false` on all required string/text columns.
- Add a composite index on `[ :account_id, :id ]` for efficient scoped lookups (optional but recommended for large tables).

```ruby
class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :account, null: false, foreign_key: true
      t.string :title, null: false
      t.text :body
      t.string :status, null: false, default: "draft"

      t.timestamps
    end

    add_index :projects, [ :account_id, :id ]
  end
end
```

> **RuboCop rule:** array literals inside index calls **must** have spaces:
> `[ :account_id, :id ]` not `[:account_id, :id]`.

Run the migration:

```bash
bin/rails db:migrate
```

Verify `db/schema.rb` reflects the new table.

#### 1c. Write the model

```ruby
# app/models/<resource>.rb
class Project < ApplicationRecord
  include AccountScoped

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[draft active archived] }
end
```

Rules:
- Use `include AccountScoped` — **never** add `belongs_to :account` manually.
- `AccountScoped` provides `belongs_to :account`, presence validation, and `.for_account` / `.for_current_account` scopes.
- Do **not** add a `default_scope`.
- Add `validates :field, presence: true` for all non-nullable string/text columns.
- For string fields with constrained values, add `inclusion:` validation.

#### 1d. Create a fixture

```yaml
# test/fixtures/<resources>.yml
one:
  account: acme
  title: Sample Project
  status: draft
  # add other required fields...

two:
  account: acme
  title: Another Project
  status: active
```

Always use the `acme` account (the canonical test fixture account).

#### 1e. Write model tests

```ruby
# test/models/<resource>_test.rb
require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "belongs to account" do
    assert_respond_to projects(:one), :account
  end

  test "valid with required attributes" do
    record = Project.new(account: accounts(:acme), title: "Test", status: "draft")
    assert record.valid?
  end

  test "invalid without title" do
    record = Project.new(account: accounts(:acme), status: "draft")
    assert_not record.valid?
    assert_includes record.errors[:title], "can't be blank"
  end

  # Repeat for each required field...

  test "does not expose records from other accounts" do
    other_account = Account.create!(name: "Other", billing_status: "trialing")
    other_record = Project.create!(account: other_account, title: "Private", status: "draft")

    scoped = Project.for_account(accounts(:acme))
    assert_not_includes scoped, other_record
  end
end
```

The tenant isolation test is **mandatory** for every scaffolded model.

---

### 2. Form object

> Full reference: [`form/SKILL.md`](../form/SKILL.md)

#### 2a. Create the form class

```ruby
# app/forms/<resource>_form.rb
class ProjectForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  # Declare all scaffold fields matching the model's columns:
  attribute :title, :string
  attribute :body, :string
  attribute :status, :string, default: "draft"

  # account is set by the controller — never from params
  attr_accessor :account

  # Expose the persisted record for post-save redirects
  attr_reader :record

  validates :title, presence: true
  validates :status, presence: true

  # Initialise from an existing record (edit) or create a new one
  def initialize(attributes = {}, record: nil)
    @record = record
    super(record ? record.attributes.symbolize_keys.merge(attributes) : attributes)
  end

  def save
    return false unless valid?

    if @record
      @record.update(form_attributes)
    else
      @record = Resource.new(form_attributes.merge(account: account))
      @record.save
    end
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.each { |error| errors.add(error.attribute, error.message) }
    false
  end

  # Needed for form_with url helpers (new vs edit path)
  def persisted?
    @record&.persisted? || false
  end

  private

  def form_attributes
    { title: title, body: body, status: status }
  end
end
```

Rules:
- Include both `ActiveModel::Model` **and** `ActiveModel::Attributes`.
- `account` is an `attr_accessor`, not an `attribute` — it is never cast from params.
- `#save` returns `true`/`false` (ActiveRecord convention); rescue `RecordInvalid` and merge errors.
- `#persisted?` must return the correct value so `form_with` generates the right URL.
- Keep `#form_attributes` private; only list the fields the form controls.

#### 2b. Write form tests

```ruby
# test/forms/<resource>_form_test.rb
require "test_helper"

class ProjectFormTest < ActiveSupport::TestCase
  def account
    accounts(:acme)
  end

  def valid_params
    { title: "My Project", status: "draft" }
  end

  test "valid with required attributes" do
    form = ProjectForm.new(valid_params)
    form.account = account
    assert form.valid?
  end

  test "invalid without title" do
    form = ProjectForm.new(valid_params.merge(title: ""))
    assert_not form.valid?
    assert form.errors[:title].any?
  end

  test "save creates a new record" do
    form = ProjectForm.new(valid_params)
    form.account = account
    assert_difference "Project.count", 1 do
      assert form.save
    end
    assert_equal account, form.record.account
  end

  test "save returns false without account" do
    form = ProjectForm.new(valid_params)
    assert_no_difference "Project.count" do
      refute form.save
    end
  end

  test "save updates an existing record" do
    project = projects(:one)
    form = ProjectForm.new({ title: "Updated" }, record: project)
    form.account = account
    assert form.save
    assert_equal "Updated", project.reload.title
  end

  test "save returns false and does not persist on validation failure" do
    form = ProjectForm.new(valid_params.merge(title: ""))
    form.account = account
    assert_no_difference "Project.count" do
      refute form.save
    end
  end
end
```

---

### 3. Controller and routes

> Full reference: [`controller/SKILL.md`](../controller/SKILL.md)

#### 3a. Create the controller

```ruby
# app/controllers/authenticated/<resources>_controller.rb
class Authenticated::ProjectsController < Authenticated::BaseController
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]

  def index
    @projects = Project.for_current_account.order(created_at: :desc)
  end

  def show
  end

  def new
    @form = ProjectForm.new
  end

  def create
    @form = ProjectForm.new(project_params)
    @form.account = Current.account

    if @form.save
      redirect_to project_path(@form.record), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @form = ProjectForm.new({}, record: @project)
  end

  def update
    @form = ProjectForm.new(project_params, record: @project)
    @form.account = Current.account

    if @form.save
      redirect_to project_path(@project), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: t(".success")
  end

  private

  def set_project
    @project = Project.for_current_account.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :body, :status)
  end
end
```

Rules:
- Always inherit from `Authenticated::BaseController` — never `ApplicationController`.
- Scope **every** `find`/`where` through `for_current_account` (never unscoped).
- Use the form object for `create` and `update`; assign `account` from `Current.account`.
- Flash notices use i18n keys: `t(".success")` — add to the resource locale file.
- `set_project` uses `for_current_account.find` — this raises `ActiveRecord::RecordNotFound` (404) if the record belongs to another account.

#### 3b. Add routes

Open `config/routes.rb` and add inside the authenticated scope:

```ruby
scope module: :authenticated do
  # ... existing routes ...
  resources :projects
end
```

Do **not** use `namespace :authenticated` — that adds the namespace prefix to URLs.

#### 3c. Write integration tests

```ruby
# test/integration/<resources>_test.rb
require "test_helper"

class ProjectsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:alice)
    @project = projects(:one)
  end

  # Authentication guard
  test "GET /projects redirects to login when unauthenticated" do
    get projects_path
    assert_redirected_to login_path
  end

  # Index
  test "GET /projects returns 200 for authenticated user" do
    sign_in_as @user
    get projects_path
    assert_response :ok
  end

  # Show
  test "GET /projects/:id returns 200" do
    sign_in_as @user
    get project_path(@project)
    assert_response :ok
  end

  # New
  test "GET /projects/new returns 200" do
    sign_in_as @user
    get new_project_path
    assert_response :ok
  end

  # Create — success
  test "POST /projects creates a project and redirects" do
    sign_in_as @user
    assert_difference "Project.count", 1 do
      post projects_path, params: { project: { title: "New Project", status: "draft" } }
    end
    assert_redirected_to project_path(Project.last)
  end

  # Create — failure
  test "POST /projects with invalid params renders new" do
    sign_in_as @user
    post projects_path, params: { project: { title: "" } }
    assert_response :unprocessable_entity
  end

  # Edit
  test "GET /projects/:id/edit returns 200" do
    sign_in_as @user
    get edit_project_path(@project)
    assert_response :ok
  end

  # Update — success
  test "PATCH /projects/:id updates and redirects" do
    sign_in_as @user
    patch project_path(@project), params: { project: { title: "Updated" } }
    assert_redirected_to project_path(@project)
    assert_equal "Updated", @project.reload.title
  end

  # Update — failure
  test "PATCH /projects/:id with invalid params renders edit" do
    sign_in_as @user
    patch project_path(@project), params: { project: { title: "" } }
    assert_response :unprocessable_entity
  end

  # Destroy
  test "DELETE /projects/:id destroys and redirects" do
    sign_in_as @user
    assert_difference "Project.count", -1 do
      delete project_path(@project)
    end
    assert_redirected_to projects_path
  end

  # Account scoping — REQUIRED
  test "cannot access another account's project" do
    other_account = Account.create!(name: "Other", billing_status: "trialing")
    other_project = Project.create!(account: other_account, title: "Private", status: "draft")

    sign_in_as @user
    get project_path(other_project)
    assert_response :not_found
  end

  private

  def sign_in_as(user)
    post login_path, params: { email: user.email, password: "password" }
  end
end
```

---

### 4. Views and i18n

Create the view directory: `app/views/authenticated/<resources>/`

#### 4a. Index view

```erb
<%# app/views/authenticated/<resources>/index.html.erb %>
<% content_for :title, t(".title") %>

<%= render UI::Authenticated::PageHeaderComponent.new(title: t(".heading"), description: t(".description")) do |header| %>
  <% header.with_actions do %>
    <%= link_to t(".new"), new_project_path, class: "btn btn-primary btn-sm" %>
  <% end %>
<% end %>

<%= render RailsFoundry::TableComponent.new(id: "<resources>-table") do %>
  <thead>
    <tr>
      <%= render RailsFoundry::Table::HeaderCellComponent.new(label: t(".table.title"), sort_key: :title) %>
      <%= render RailsFoundry::Table::HeaderCellComponent.new(label: t(".table.status"), sort_key: :status) %>
      <%= render RailsFoundry::Table::HeaderCellComponent.new(label: t(".table.created_at"), sort_key: :created_at) %>
      <%= render RailsFoundry::Table::HeaderCellComponent.new(label: t(".table.actions")) %>
    </tr>
  </thead>
  <tbody>
    <% if @projects.empty? %>
      <tr>
        <td colspan="4" class="text-center py-8 text-base-content/50"><%= t(".empty") %></td>
      </tr>
    <% else %>
      <% @projects.each do |project| %>
        <tr class="hover:bg-base-200 transition-colors">
          <%= render RailsFoundry::Table::BodyCellComponent.new do %>
            <%= link_to project.title, project_path(project), class: "link link-hover font-medium" %>
          <% end %>
          <%= render RailsFoundry::Table::BodyCellComponent.new do %>
            <%= project.status %>
          <% end %>
          <%= render RailsFoundry::Table::BodyCellComponent.new do %>
            <%= l project.created_at, format: :short %>
          <% end %>
          <%= render RailsFoundry::Table::BodyCellComponent.new do %>
            <%= link_to t(".edit"), edit_project_path(project), class: "btn btn-ghost btn-xs" %>
            <%= button_to t(".delete"), project_path(project), method: :delete,
                class: "btn btn-error btn-xs",
                form: { data: { turbo_confirm: t(".confirm_delete") } } %>
          <% end %>
        </tr>
      <% end %>
    <% end %>
  </tbody>
<% end %>
```

#### 4b. Show view

```erb
<%# app/views/authenticated/<resources>/show.html.erb %>
<% content_for :title, @project.title %>

<%= render UI::Authenticated::PageHeaderComponent.new(title: @project.title) do |header| %>
  <% header.with_actions do %>
    <%= link_to t(".edit"), edit_project_path(@project), class: "btn btn-outline btn-sm" %>
    <%= button_to t(".delete"), project_path(@project), method: :delete,
        class: "btn btn-error btn-sm",
        form: { data: { turbo_confirm: t(".confirm_delete") } } %>
  <% end %>
<% end %>

<%= render UI::CardComponent.new do %>
  <%# Render each field %>
  <div class="space-y-4">
    <div>
      <p class="text-sm font-medium text-base-content/60"><%= t(".labels.status") %></p>
      <p><%= @project.status %></p>
    </div>
    <%# Add remaining fields... %>
  </div>
<% end %>
```

#### 4c. New view

```erb
<%# app/views/authenticated/<resources>/new.html.erb %>
<% content_for :title, t(".title") %>

<%= render UI::Authenticated::PageHeaderComponent.new(title: t(".heading")) %>

<%= render "form", form: @form, url: projects_path %>
```

#### 4d. Edit view

```erb
<%# app/views/authenticated/<resources>/edit.html.erb %>
<% content_for :title, t(".title") %>

<%= render UI::Authenticated::PageHeaderComponent.new(title: t(".heading")) %>

<%= render "form", form: @form, url: project_path(@project) %>
```

#### 4e. Form partial

```erb
<%# app/views/authenticated/<resources>/_form.html.erb %>
<%= render UI::CardComponent.new do %>
  <%= form_with model: form, url: url, scope: :project, class: "space-y-4" do |f| %>

    <%# string field example %>
    <%= render Form::ControlComponent.new(form: f, attribute: :title) do |field| %>
      <% field.with_input do %>
        <%= render Form::InputComponent.new(form: f, attribute: :title, type: :text) %>
      <% end %>
    <% end %>

    <%# text field example %>
    <%= render Form::ControlComponent.new(form: f, attribute: :body) do |field| %>
      <% field.with_input do %>
        <%= render Form::InputComponent.new(form: f, attribute: :body, type: :textarea) %>
      <% end %>
    <% end %>

    <%# Add remaining fields following the type mapping in Step 0... %>

    <div class="card-actions justify-end">
      <%= link_to t(".cancel"), projects_path, class: "btn btn-ghost" %>
      <%= f.submit t(".submit"), class: "btn btn-primary" %>
    </div>
  <% end %>
<% end %>
```

#### 4f. i18n locale file

Create `config/locales/<resources>.en.yml`. Include keys for every view:

```yaml
en:
  authenticated:
    projects:
      index:
        title: Projects
        heading: Projects
        description: Manage your projects.
        new: New project
        empty: No projects yet.
        edit: Edit
        delete: Delete
        confirm_delete: Are you sure you want to delete this project?
        table:
          title: Title
          status: Status
          created_at: Created
          actions: Actions
      show:
        edit: Edit
        delete: Delete
        confirm_delete: Are you sure you want to delete this project?
        labels:
          status: Status
      new:
        title: New Project
        heading: New project
      edit:
        title: Edit Project
        heading: Edit project
      form:
        cancel: Cancel
        submit: Save project
      create:
        success: Project was created successfully.
      update:
        success: Project was updated successfully.
      destroy:
        success: Project was deleted.
```

> **Rule:** Every string in every view template must have a corresponding key in this file.
> No hardcoded English text in `.html.erb` files.

#### 4g. System tests

Use the `system_test` skill for the `[UI story]` criteria.

Create `test/system/authenticated/<resources>_test.rb`:

```ruby
require "test_helper"

class Authenticated::ProjectsSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:alice)
    sign_in_as @user
  end

  test "user can create a project" do
    visit new_project_path

    fill_in "Title", with: "My New Project"
    click_on "Save project"

    assert_text "Project was created successfully"
    assert_current_path project_path(Project.last)
  end

  test "user can view a project" do
    project = projects(:one)
    visit project_path(project)

    assert_text project.title
  end

  test "user can edit a project" do
    project = projects(:one)
    visit edit_project_path(project)

    fill_in "Title", with: "Updated Title"
    click_on "Save project"

    assert_text "Project was updated successfully"
    assert_text "Updated Title"
  end

  test "user can delete a project" do
    project = projects(:one)
    visit projects_path

    # Confirm the project appears in the list
    assert_text project.title

    # Use button_to DELETE (rack_test handles turbo_confirm via accept_confirm)
    page.accept_confirm do
      click_on "Delete"
    end

    assert_text "Project was deleted"
    assert_no_text project.title
  end
end
```

> For rack_test driver (default): turbo_confirm dialogs are automatically accepted.
> If you add `driven_by :selenium, using: :headless_chrome` override, use `accept_confirm`.

---

### 5. Sidebar navigation

#### 5a. Ask the developer

Before editing the layout, ask:

1. **Which sidebar section?** Show the existing sections from `authenticated.html.erb`
   (e.g. "Main", "Account") so the developer can choose or create a new one.
2. **Which icon?** Suggest a relevant Heroicon name (e.g. `"folder"`, `"document-text"`,
   `"briefcase"`, `"squares-2x2"`). See [heroicons.com](https://heroicons.com) for options.

#### 5b. Edit the layout

Open `app/views/layouts/authenticated.html.erb`. Locate the `nav_sections:` array
passed to `UI::Authenticated::SidebarComponent`:

```erb
<%= render UI::Authenticated::SidebarComponent.new(
  ...
  nav_sections: [
    {
      label: t("authenticated.layout.sections.main"),
      items: [
        { label: t("authenticated.layout.nav.dashboard"), href: dashboard_path, icon: "home" },
        # ↓ Add your new item here (or in the appropriate section)
        { label: t("authenticated.layout.nav.projects"), href: projects_path, icon: "folder" }
      ]
    },
    ...
  ]
) %>
```

Rules:
- Add the item to the **appropriate existing section** — do not create a new section
  unless the developer explicitly requests it.
- Use the `t()` helper for the label — never hardcode the nav label string.
- The `href:` must use a named route helper (e.g. `projects_path`).
- The `icon:` value is a Heroicon slug string (outline variant is default).

#### 5c. Add the i18n key

Open `config/locales/en.yml` and add the nav key under `authenticated.layout.nav`:

```yaml
en:
  authenticated:
    layout:
      nav:
        # existing keys...
        projects: Projects
```

Do **not** add the key to the resource-specific locale file (`config/locales/projects.en.yml`).
Nav labels belong in the shared `en.yml`.

#### 5d. Write a navigation integration test

Add a test to `test/integration/sidebar_navigation_test.rb` (or create it if absent):

```ruby
test "authenticated user sees projects link in sidebar" do
  sign_in_as users(:alice)
  get dashboard_path
  assert_select "a[href='#{projects_path}']"
end
```

If the sidebar renders via a ViewComponent, the link will be present in the HTML response
and `assert_select` will find it without needing a system test.

---

## Verify

After all steps:

```bash
bin/ci
```

CI must be green before the scaffold is considered complete. Fix any failures before
handing off to the developer.

---

## Checklist

- [ ] Resource name and fields confirmed with developer
- [ ] Model created with `AccountScoped`, validations, fixture, and tests
- [ ] Migration has `null: false` on required columns and `foreign_key: true` on account
- [ ] Form object created with `#save`, validations, and tests
- [ ] Controller created in `Authenticated::` namespace with all 7 CRUD actions
- [ ] All queries scoped to `Current.account`
- [ ] Routes added inside authenticated scope
- [ ] Integration tests cover all CRUD actions + account-scoping
- [ ] Views generated: index, show, new, edit, _form
- [ ] Views use `RailsFoundry::TableComponent`, `UI::CardComponent`, `Form::ControlComponent`
- [ ] i18n locale file created — no hardcoded strings in views
- [ ] System tests cover create, view, edit, delete user flows
- [ ] Sidebar navigation item added with correct icon and i18n key
- [ ] `bin/ci` passes
