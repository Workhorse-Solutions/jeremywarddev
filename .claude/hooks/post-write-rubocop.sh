#!/usr/bin/env bash
# Post-tool hook: auto-correct RuboCop offenses after any Ruby file write.
#
# Triggered by PostToolUse on Write | Edit | MultiEdit tools.
# Claude Code passes the tool context as JSON on stdin.
#
# Exits 0 (non-blocking) in all cases — rubocop output is informational only.

set -euo pipefail

input=$(cat)
path=$(echo "$input" | jq -r '.tool_input.path // empty' 2>/dev/null || true)

# Only act on Ruby files
[[ "$path" == *.rb ]] || exit 0

# Resolve absolute path relative to the project root when needed
if [[ "$path" != /* ]]; then
  path="$(pwd)/$path"
fi

[[ -f "$path" ]] || exit 0

echo "rubocop: autocorrecting $path"
bin/rubocop --autocorrect "$path" 2>&1 | tail -5 || true
