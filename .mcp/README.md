# .mcp/ — MCP Client Configuration Examples

This directory contains example MCP client configuration files.

Each file is an **example** — copy and adapt it for your machine.
None of these files are gitignored; they contain no secrets.

---

## Files

| File | Target client | Where to put it |
|---|---|---|
| `claude-code.example.json` | Claude Code (built-in workspace MCP) | Copy to `.mcp.json` at project root |
| `claude-desktop.example.json` | Claude Desktop (Anthropic app) | Merge into `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) |
| `cursor.example.json` | Cursor IDE | Merge into `~/.cursor/mcp.json` |
| `vscode.example.json` | VS Code (GitHub Copilot MCP) | Copy to `.vscode/mcp.json` |

---

## Recommended server: rails-mcp-server

All configs use `bin/mcp`, which wraps `rails-mcp-server`.

Install once:
```bash
npm install -g rails-mcp-server
```

Or let `bin/mcp` use `npx` on first run (no global install required).

---

## Alternative: rails-active-mcp (Ruby gem)

`rails-active-mcp` runs inside your Rails process and exposes ActiveRecord
tools (query, schema inspection, model introspection) over MCP.

Add to your `Gemfile` (development group):
```ruby
gem "rails-active-mcp", require: false
```

Then:
```bash
bundle install
bundle exec rails active_mcp:server
```

Client config command: `bundle exec rails active_mcp:server`

Prefer `rails-mcp-server` for general codebase context; use `rails-active-mcp`
when you specifically need live ActiveRecord query access.
