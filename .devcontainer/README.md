# Dev Container

This directory configures the VS Code Dev Container for RailsFoundry.

## Claude Code

The [Claude Code](https://www.anthropic.com/claude-code) CLI and VS Code extension are pre-installed in the container.

### Setup

1. **Rebuild the container** — open the Command Palette and run
   `Dev Containers: Rebuild Container`. The `anthropic.claude-code` extension
   and the `claude` CLI are installed automatically during setup.

2. **Authenticate** — open a terminal inside the container and run:
   ```sh
   claude
   ```
   Follow the prompts to log in with your Anthropic account.

### Persistent config

Claude auth and configuration are stored in a named Docker volume mounted at:

```
/home/vscode/.claude
```

The `CLAUDE_CONFIG_DIR` environment variable is set to the same path so the
CLI and extension always find your credentials.

Because this is a **named volume** (`claude-config-${devcontainerId}`), your
login survives container rebuilds. You only need to authenticate once per
machine.
