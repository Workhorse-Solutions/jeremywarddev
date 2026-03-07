# RailsFoundry

Rails 8 template with Postgres, Tailwind/DaisyUI, and Solid Queue.

## Quick Start

```bash
git clone git@github.com:Workhorse-Solutions/rails-foundry.git my_app
cd my_app
git remote rename origin upstream
git remote add origin git@github.com:YOUR_ORG/my_app.git
bin/foundry setup          # prompts for APP_NAME and APP_IDENTIFIER
bundle install
bin/rails db:create db:migrate
bin/dev                    # visit http://localhost:3000
```

This keeps `upstream` pointed at RailsFoundry (for pulling future template
updates) and sets `origin` to your own repository.

`bin/foundry setup` writes a `.env` file with your app's unique identity values:

| Variable | Description | Example |
|---|---|---|
| `APP_NAME` | Human-readable display name | `Workhorse Rental` |
| `APP_IDENTIFIER` | snake\_case slug — **must be unique per cloned app** | `workhorse_rental` |

`APP_IDENTIFIER` determines Postgres database names, the session cookie key,
the Docker Compose project name, and the Kamal service name. Every app cloned
from this template **must** use a distinct `APP_IDENTIFIER` to prevent
collisions on the same machine.

### VS Code Dev Containers

1. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) for VS Code.
2. Copy `.devcontainer/.env.example` to `.devcontainer/.env` and set your `APP_IDENTIFIER` / `APP_NAME`.
3. Open this repository in VS Code and click **Reopen in Container** when prompted.
4. VS Code will build the Docker image, start the `app` and `db` services, and run `bundle install` / `bin/setup` automatically.
5. Once the container is ready, open a terminal and run:

   ```bash
   bin/dev
   ```

6. Visit [http://localhost:3000](http://localhost:3000).

**Required ports:** `3000` (Rails), `5432` (Postgres)

### Local Setup (without Dev Containers)

Ensure you have Ruby 3.4.x, Node 20, Yarn, and Postgres installed locally, then run:

```bash
bin/setup
bin/dev
```

## Stack

* Ruby version: 3.4.x
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

When working with an agent, point it at `AGENTS.md` first.

### Installing AI tooling (skills & hooks)

Agent skills and Claude Code hooks are bundled in the `rails_foundry_cli` gem.
The gem is listed in the Gemfile but gated behind the `FOUNDRY_CLI` environment
variable so it does not interfere with CI or production installs.

> **Important:** `FOUNDRY_CLI` must be set as a **shell environment variable**
> — Bundler does not read `.env` files. Always prefix the command or `export`
> the variable in your shell.

1. **Ensure SSH access** to the private gem repo (one-time setup).
   You need `read` access to [`Workhorse-Solutions/rails-foundry-cli`](https://github.com/Workhorse-Solutions/rails-foundry-cli)
   and an SSH key configured with GitHub. Verify with:

   ```bash
   ssh -T git@github.com
   ```

2. **Install the gem:**

   ```bash
   FOUNDRY_CLI=1 bundle install
   ```

3. **Generate the AI tooling files:**

   ```bash
   rails generate rails_foundry_cli:ai_tooling
   ```

This copies the `.claude/` directory (skills, hooks, settings) into your project. Re-run after upgrading the gem to pull in updated skills.

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

Enter `Ctrl-C` to stop — in normal use, your MCP client starts it automatically.

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
