#!/usr/bin/env bash
# secret-scan.sh — PreToolUse hook for Write and Edit tools.
#
# Scans the content about to be written/edited for secrets (API keys, tokens,
# .env-shaped strings, AWS/GitHub/Stripe/Anthropic key signatures). Blocks the
# write if found. Saves the inevitable "I accidentally committed a key" incident.
#
# Discipline: success is silent. Block output goes to stderr and is read by the model.
#
# Install: copy to ~/.claude/hooks/secret-scan.sh, chmod +x, reference from settings.json.

set -e

payload=$(cat)

# Extract the file path and content the agent intends to write.
if command -v jq >/dev/null 2>&1; then
  path=$(echo "$payload" | jq -r '.tool_input.file_path // .tool_input.path // empty')
  content=$(echo "$payload" | jq -r '.tool_input.content // .tool_input.new_string // empty')
else
  # jq is strongly recommended; this fallback is best-effort only.
  path=$(echo "$payload" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed -E 's/.*"file_path"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')
  content=$(echo "$payload" | tr -d '\n')
fi

# Skip the scan for non-text destinations we cannot reason about.
case "$path" in
  *.bin|*.png|*.jpg|*.jpeg|*.gif|*.webp|*.mp4|*.mov|*.zip|*.tar|*.gz) exit 0 ;;
esac

# Pattern set. Each match aborts the write.
patterns=(
  # Anthropic (dashes written as [-] so this source file does not itself trip a parent secret-scanner)
  'sk[-]ant[-]api[0-9]{2}[-][A-Za-z0-9_-]{20,}'
  # OpenAI
  'sk-[A-Za-z0-9]{32,}'
  # Stripe
  'sk_live_[A-Za-z0-9]{24,}'
  'rk_live_[A-Za-z0-9]{24,}'
  # AWS access key
  'AKIA[0-9A-Z]{16}'
  # GitHub personal access token
  'ghp_[A-Za-z0-9]{36,}'
  'github_pat_[A-Za-z0-9_]{40,}'
  # Generic high-entropy "secret" assignments
  'API_KEY[[:space:]]*=[[:space:]]*[a-zA-Z0-9_]{30,}'
  'SECRET[[:space:]]*=[[:space:]]*[a-zA-Z0-9_]{30,}'
  'PASSWORD[[:space:]]*=[[:space:]]*[^[:space:]"]{8,}'
  # Private key headers
  '-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY'
)

for pat in "${patterns[@]}"; do
  if echo "$content" | grep -qE "$pat"; then
    echo "BLOCKED by secret-scan: content matches secret pattern: $pat" >&2
    echo "Target file: $path" >&2
    echo "If this is a deliberate example or placeholder, replace the real value with a clearly fake one (e.g. PROVIDER-PREFIX-EXAMPLE-VALUE-HERE) and retry." >&2
    exit 2
  fi
done

# Refuse to write .env files at all from the agent.
case "$path" in
  *.env|*.env.local|*.env.production|.env|.env.*|*credentials.json|*credentials.yaml)
    echo "BLOCKED by secret-scan: writes to environment / credential files are not permitted." >&2
    echo "Target file: $path" >&2
    exit 2
    ;;
esac

exit 0
