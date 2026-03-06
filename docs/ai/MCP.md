# MCP Support in RailsFoundry

## What is MCP?

Model Context Protocol (MCP) is an open standard that allows AI agents (Claude Code,
GitHub Copilot, etc.) to call external tools and services directly during a session.
Instead of asking you to copy-paste API responses, an agent with MCP can query Stripe,
inspect your Rails schema, or read credentials — all within its context window.

RailsFoundry ships with first-class MCP configuration for the tools most useful during
Rails SaaS development.

---

## Supported MCP Servers

### Rails (recommended default)

`rails-mcp-server` (npm package) gives agents project-aware context: routes, schema,
models, jobs, and gem dependencies. It runs locally via `bin/mcp`.

Install once:
```bash
npm install -g rails-mcp-server
```

`bin/mcp` falls back to `npx` automatically if the package is not globally installed.

### Stripe

The official [Stripe MCP server](https://github.com/stripe/stripe-mcp) exposes the
Stripe API to agents. When active, an agent can look up customers, subscriptions,
invoices, and prices without leaving the coding session.

### Alternative: rails-active-mcp (Ruby gem)

`rails-active-mcp` runs inside your Rails process and provides live ActiveRecord query
access over MCP. Add to `Gemfile` (development group) and run with
`bundle exec rails active_mcp:server`. See `.mcp/README.md` for details.

---

## Architectural Boundary

```
Rails credentials (credentials.yml.enc)
        │
        │  bin/foundry export-secrets
        ▼
.env.local  (gitignored, machine-local)
        │
        │  environment variable interpolation
        ▼
.mcp.json  (gitignored, per-developer)
        │
        │  MCP client reads config, spawns servers
        ▼
 bin/mcp                     stripe-mcp
(rails-mcp-server)           (Stripe API)
```

**Rules:**

- `credentials.yml.enc` is the canonical secret store. Never move secrets out of it.
- `.env.local` is generated from credentials. It is gitignored and machine-local.
- `.mcp.json` references environment variables only. It never contains real secrets.
- Neither `.env.local` nor `.mcp.json` is committed to the repository.

---

## Workflow

### 1. Install the Rails MCP server

```bash
npm install -g rails-mcp-server
# or let bin/mcp use npx (no global install needed)
```

### 2. Add the Stripe key to credentials

```bash
bin/rails credentials:edit
```

Add under the `stripe` namespace:

```yaml
stripe:
  secret_key: sk_live_…
```

Save and close. The encrypted credentials file is committed. The key is not.

### 3. Export secrets to .env.local

```bash
bin/foundry export-secrets
```

This runs Rails runner to extract `Rails.application.credentials.dig(:stripe, :secret_key)`
and writes it to `.env.local` as `STRIPE_API_KEY=<value>`. Existing unrelated lines in
`.env.local` are preserved.

### 4. Verify the MCP server starts

```bash
bin/mcp
# Rails MCP Server
#   Project root : /path/to/project
#   Transport    : stdio
```

`Ctrl-C` to stop. In normal use, your MCP client starts `bin/mcp` automatically.

### 5. Create your local .mcp.json

```bash
cp .mcp.json.example .mcp.json
source .env.local   # or configure direnv
```

`.mcp.json` uses `bin/mcp` as the command for the Rails server and reads `STRIPE_API_KEY`
from the environment. See `.mcp/` for examples targeting other clients (Claude Desktop,
Cursor, VS Code).

### 6. Restart your agent

Claude Code (or whichever agent you use) picks up `.mcp.json` on startup. Restart the
agent session to activate the new MCP servers. For Claude Desktop, Cursor, and VS Code,
see `.mcp/` for the matching example config files.

---

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| `export-secrets` prints "stripe.secret_key not found" | Credentials not set — run `bin/rails credentials:edit` |
| MCP server says `STRIPE_API_KEY` is missing | `.env.local` not sourced in shell — run `source .env.local` or configure `direnv` |
| `bin/mcp` exits immediately | `rails-mcp-server` and `npx` both unavailable — install Node 18+ |
| Agent can't find `rails-mcp-server` | Package not installed — run `npm install -g rails-mcp-server` |
| Agent says "no MCP tools available" | `.mcp.json` missing or not reloaded — copy example and restart agent |

---

## Non-Goals

- Postgres MCP is not configured here (no secrets to export; add if needed).
- Do not add MCP servers that require committing secrets.
- Do not store `.mcp.json` in the repository.
