#!/usr/bin/env bash
# fs-guard.sh — PreToolUse hook for the Bash tool.
#
# Blocks destructive filesystem operations before they execute. Catches the catastrophic
# mistake that the model occasionally produces (rm -rf ~, recursive chmod on Dropbox,
# xattr commands on synced folders). Output exit 2 with a one-line reason is read by
# the model and surfaced in the session.
#
# Discipline: success is silent, failures are verbose. Exit 0 means "let the call through".
# Exit 2 means "block, here is why".
#
# Install: copy to ~/.claude/hooks/fs-guard.sh, chmod +x, reference from settings.json.

set -e

# Read the JSON stdin payload that Claude Code sends to PreToolUse hooks.
payload=$(cat)

# Extract the Bash command. Requires jq; fall back to grep if unavailable.
if command -v jq >/dev/null 2>&1; then
  cmd=$(echo "$payload" | jq -r '.tool_input.command // empty')
else
  cmd=$(echo "$payload" | grep -oE '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"command"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
fi

# Empty command means not a Bash call we recognise. Let it through.
if [ -z "$cmd" ]; then
  exit 0
fi

# Deny rules. Each pattern is a regex matched against the full command string.
# Add to this list every time you observe a near-miss.
deny_patterns=(
  'rm[[:space:]]+-rf?[[:space:]]+/'
  'rm[[:space:]]+-rf?[[:space:]]+~'
  'rm[[:space:]]+-rf?[[:space:]]+\*'
  'rm[[:space:]]+-rf?[[:space:]]+\.($|[[:space:]])'
  'chmod[[:space:]]+-R[[:space:]]'
  'chown[[:space:]]+-R[[:space:]]'
  'xattr[[:space:]]'
  'touch[[:space:]]+-r[[:space:]]'
  '\.dropbox(/|$)'
  '\.dropbox-master(/|$)'
  '--no-verify'
  '--no-gpg-sign'
  'git[[:space:]]+push[[:space:]]+(--force|-f)[[:space:]]+origin[[:space:]]+(main|master)'
  'git[[:space:]]+reset[[:space:]]+--hard[[:space:]]+origin/'
  '>[[:space:]]*\.env'
  'dd[[:space:]]+if=/dev/zero'
  'dd[[:space:]]+if=/dev/random'
  ':[(]:[)]\{:\|:&\};:'
)

for pat in "${deny_patterns[@]}"; do
  if [[ "$cmd" =~ $pat ]]; then
    echo "BLOCKED by fs-guard: command matches deny pattern: $pat" >&2
    echo "Command was: $cmd" >&2
    echo "If this is intentional, run it in an isolated environment (Docker, devcontainer)." >&2
    exit 2
  fi
done

# Silent on success.
exit 0
