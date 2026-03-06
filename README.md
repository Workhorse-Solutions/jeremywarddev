# RailsFoundry

Rails 8 template with Postgres, Tailwind/DaisyUI, and Solid Queue.

## Development Setup

### Recommended: VS Code Dev Containers

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for VS Code.
2. Open this repository in VS Code.
3. When prompted, click **Reopen in Container** (or run the command **Dev Containers: Reopen in Container**).
4. VS Code will build the Docker image, start the `app` and `db` services, and run `bundle install` / `bin/setup` automatically.
5. Once the container is ready, open a terminal and run:

   ```bash
   bin/dev
   ```

6. Visit [http://localhost:3000](http://localhost:3000).

**Required ports:** `3000` (Rails), `5432` (Postgres)

### Alternative: Local Setup

Ensure you have Ruby 3.3.x, Node 20, Yarn, and Postgres installed locally, then run:

```bash
bin/setup
bin/dev
```

## Make it yours

When you clone RailsFoundry for a new project, run the setup command to
generate a `.env` file with your app's unique identity values:

```bash
bin/foundry setup
```

This will prompt you for:

| Variable | Description | Example |
|---|---|---|
| `APP_NAME` | Human-readable display name | `Workhorse Rental` |
| `APP_IDENTIFIER` | snake\_case slug — **must be unique per cloned app** | `workhorse_rental` |

`APP_IDENTIFIER` determines Postgres database names, the session cookie key,
the Docker Compose project name, and the Kamal service name. Every app cloned
from this template **must** use a distinct `APP_IDENTIFIER` to prevent
collisions on the same machine.

After running `bin/foundry setup`:

```bash
bin/rails db:create db:migrate
bin/dev
```

## Stack

* Ruby version: 3.3.x
* Database: PostgreSQL 16
* Asset pipeline: Propshaft + Tailwind CSS + DaisyUI
* Background jobs: Solid Queue
* JavaScript: Stimulus + Turbo (import maps)

## AI-Native Workflow

RailsFoundry is structured to work well with AI agents (Claude Code, GitHub Copilot, etc.).

- **[AGENTS.md](AGENTS.md)** — canonical instructions for all agents: stack, non-negotiables, and task format
- **[CLAUDE.md](CLAUDE.md)** — short pointer file for Claude Code
- **[docs/ai/STACK.md](docs/ai/STACK.md)** — stack details and key config locations
- **[docs/ai/WORKFLOWS.md](docs/ai/WORKFLOWS.md)** — verify-first workflow, PR size rules, security-sensitive areas
- **[.claude/skills/](.claude/skills/README.md)** — reusable, versioned agent task workflows

When working with an agent, point it at `AGENTS.md` first.

## MCP Setup

RailsFoundry ships first-class support for the [Model Context Protocol](https://modelcontextprotocol.io/).
MCP lets AI agents (Claude Code, Claude Desktop, Cursor, VS Code Copilot) query your
codebase, schema, routes, and the Stripe API directly, without copy-pasting.

**Default server:** [`rails-mcp-server`](https://github.com/mrsked/mrsk) (Node.js, no gem required)
**Alternative:** [`rails-active-mcp`](https://github.com/ajay-dhangar/rails-active-mcp) Ruby gem — see `.mcp/README.md`

### Prerequisites

- Node 18+ (`node --version`)
- npm 8+ (`npm --version`)

### 1. Install the Rails MCP server

```bash
npm install -g rails-mcp-server
```

Or skip the global install — `bin/mcp` will fall back to `npx` automatically.

### 2. Add your Stripe key to credentials (optional for Stripe MCP)

```bash
bin/rails credentials:edit
```

Add under the `stripe` namespace:

```yaml
stripe:
  secret_key: sk_live_…
```

### 3. Export secrets to .env.local

```bash
bin/foundry export-secrets
# writes STRIPE_API_KEY=… to .env.local (gitignored)
```

### 4. Create your local .mcp.json

```bash
cp .mcp.json.example .mcp.json
source .env.local   # make STRIPE_API_KEY available, or configure direnv
```

### 5. Verify the Rails MCP server starts

```bash
bin/mcp
# Rails MCP Server
#   Project root : /path/to/project
#   Transport    : stdio
```

Inter `Ctrl-C` to stop — in normal use, your MCP client starts it automatically.

### 6. Restart your agent

| Client | Action |
|---|---|
| **Claude Code** | Reload window (`Cmd+Shift+P` → "Developer: Reload Window") |
| **Claude Desktop** | Quit and reopen the app |
| **Cursor** | Restart Cursor |
| **VS Code** | Copy `.mcp/vscode.example.json` → `.vscode/mcp.json`, then reload window |

For Claude Desktop and Cursor, merge the snippet from the relevant file inside `.mcp/`
into your client's global MCP config (replacing `/absolute/path/to/project`).

### Verification Checklist

Once connected, ask your agent each of these to confirm MCP is live:

1. **List routes** — "What routes does this app expose?" The agent should enumerate controllers and actions from `config/routes.rb`.
2. **Inspect schema** — "Show me the database schema." It should read `db/schema.rb` and describe all tables.
3. **Find a model** — "What does the ApplicationRecord look like?" It should read `app/models/application_record.rb`.
4. **Check jobs** — "What background jobs are defined?" It should find files under `app/jobs/`.
5. **List gems** — "What gems does this app use?" It should parse `Gemfile` and summarise dependencies.
6. **Read a config** — "How is the session store configured?" It should find `config/initializers/session_store.rb`.
7. **Stripe (if configured)** — "List my Stripe products." Should return live data via the Stripe MCP server.
8. **Run a test** — "Run the test suite and show me the output." Agent should invoke `bin/rails test`.

### Troubleshooting

| Symptom | Fix |
|---|---|
| `rails-mcp-server: command not found` | Run `npm install -g rails-mcp-server` or ensure Node is on `$PATH` |
| `bin/mcp` hangs silently | Normal — stdio transport waits for a client. Use `Ctrl-C`; let your MCP client invoke it. |
| `STRIPE_API_KEY` missing | Run `bin/foundry export-secrets` then `source .env.local` |
| Agent says "no MCP tools available" | Check `.mcp.json` exists at project root; reload your agent window |
| `export-secrets` prints "stripe.secret_key not found" | Add key via `bin/rails credentials:edit` |

See [docs/ai/MCP.md](docs/ai/MCP.md) for the full architecture reference.

## Running Tests

```bash
bin/rails test
```

## Name Hygiene — Avoiding Collisions When Cloning

RailsFoundry is a template intended to be cloned for multiple apps. Every
collision-sensitive identifier (Postgres database name, session cookie key,
Kamal service name, Docker Compose project name) is derived from a single
environment variable: **`APP_IDENTIFIER`**.

### Variables

| Variable | Purpose | Default |
|---|---|---|
| `APP_IDENTIFIER` | snake\_case slug used for DB names, session key, and deploy service name | `railsfoundry` |
| `APP_NAME` | Human-readable display name | `RailsFoundry` |

### Why it matters

| Collision point | How it is set |
|---|---|
| Postgres DB name | `<%= ENV.fetch("APP_IDENTIFIER", "railsfoundry") %>_development` in `database.yml` |
| Session cookie key | `_#{RailsFoundry.config.app_identifier}_session` in `session_store.rb` |
| Docker Compose project | `${APP_IDENTIFIER:-railsfoundry}` in `.devcontainer/docker-compose.yml` |
| Kamal service / image | `<%= ENV.fetch("APP_IDENTIFIER", "railsfoundry") %>` in `deploy.yml` |

Without a unique `APP_IDENTIFIER`, two apps on the same machine will:
- share or corrupt each other's **session cookies** (same key on `localhost`)
- target the **same Postgres database** (potentially destroying data)

### Setting up a new app from this template

1. Generate `.env` with your app's unique values using the setup command:

   ```bash
   bin/foundry setup
   ```

   Or copy manually and edit:

   ```bash
   cp .env.example .env
   ```

   ```dotenv
   APP_NAME=Workhorse Rental
   APP_IDENTIFIER=workhorse_rental
   ```

2. For the devcontainer, copy `.devcontainer/.env.example` to `.devcontainer/.env`
   and set the same values there before opening the container. Docker Compose
   reads that file automatically via `${APP_IDENTIFIER:-railsfoundry}` substitution.

   ```bash
   cp .devcontainer/.env.example .devcontainer/.env
   # then edit .devcontainer/.env with your APP_IDENTIFIER / APP_NAME
   ```

3. Run `bin/rails db:create db:migrate` to create fresh databases under the
   new identifier.
