#!/usr/bin/env bash
# Syncs ~/.docker/config.json from a GitHub Codespace, preserving local-only fields.
set -e

CODESPACE="${1:-}"

if [[ -z "$CODESPACE" ]]; then
  echo "Usage: sync-docker-config <codespace-name>" >&2
  echo "" >&2
  echo "Available codespaces:" >&2
  gh codespace list
  exit 1
fi

LOCAL_CONFIG="$HOME/.docker/config.json"

# Pull config from codespace
REMOTE=$(gh codespace ssh --codespace "$CODESPACE" -- "cat ~/.docker/config.json" 2>/dev/null)

if [[ -z "$REMOTE" ]]; then
  echo "Error: could not read ~/.docker/config.json from codespace '$CODESPACE'" >&2
  exit 1
fi

# Preserve local-only fields, merge remote auths/credHelpers/HttpHeaders on top
MERGED=$(jq -n \
  --argjson remote "$REMOTE" \
  --argjson local "$(cat "$LOCAL_CONFIG")" \
  '$remote + { credsStore: $local.credsStore, currentContext: $local.currentContext }')

echo "$MERGED" > "$LOCAL_CONFIG"
echo "~/.docker/config.json updated from codespace '$CODESPACE'"
