# Dev Container

This directory configures the VS Code Dev Container for RailsFoundry.

## SSH Access to GitHub

The `postCreateCommand` in `devcontainer.json` runs `ssh-keyscan github.com`
on container creation so GitHub is automatically trusted. This is required for
installing the `rails_foundry_cli` gem, which is fetched via SSH.

You also need your **local SSH agent** running with your key loaded:

```sh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519   # or your key path
```

VS Code forwards the agent into the container automatically. Verify with:

```sh
ssh -T git@github.com
```

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
