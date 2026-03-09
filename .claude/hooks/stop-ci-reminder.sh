#!/usr/bin/env bash
# Stop hook: remind the agent that bin/ci must pass before work is complete.
#
# Triggered when Claude finishes a response.
# Does NOT block — it only prints a reminder to Claude's context.

cat <<'EOF'
──────────────────────────────────────────────────────
  BEFORE MARKING THIS TASK COMPLETE:
  → Run `bin/ci` and confirm it exits successfully.
  → A task is not done until CI passes.
──────────────────────────────────────────────────────
EOF
