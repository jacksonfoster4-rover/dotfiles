#!/usr/bin/env bash
# Launch wrapper for the codespace-tmux MCP server.
#
# The local MCP client (Claude) points at THIS script instead of `gh` directly,
# so the codespace name is resolved at launch time rather than hardcoded in
# ~/.claude.json. When a codespace is rebuilt/renamed, nothing needs editing.
#
# Resolution order:
#   1. $CODESPACE_TMUX_NAME  -- explicit override, if you want to pin one.
#   2. $CODESPACE_TMUX_REPO  -- repo to search (default roverdotcom/web).
#   3. First codespace GitHub reports for that repo.
#
# stdout MUST stay clean (it is the MCP stdio transport) -- all diagnostics go
# to stderr, which the client surfaces on connection failure.
set -euo pipefail

REPO="${CODESPACE_TMUX_REPO:-roverdotcom/web}"
REMOTE_PYTHON="${CODESPACE_TMUX_PYTHON:-~/.tmux-mcp-venv/bin/python}"
REMOTE_SERVER="${CODESPACE_TMUX_SERVER:-/workspaces/.codespaces/.persistedshare/dotfiles/bin/tmux-mcp-server.py}"

name="${CODESPACE_TMUX_NAME:-}"
if [[ -z "$name" ]]; then
  name="$(gh codespace list --json name,repository \
    --jq ".[] | select(.repository==\"$REPO\") | .name" 2>/dev/null | head -1)"
fi

if [[ -z "$name" ]]; then
  echo "codespace-tmux-launch: no codespace found for repo '$REPO'." >&2
  echo "  Create one, or set CODESPACE_TMUX_NAME / CODESPACE_TMUX_REPO." >&2
  exit 1
fi

echo "codespace-tmux-launch: targeting codespace '$name' ($REPO)" >&2

# `gh codespace ssh` auto-starts a stopped codespace on connect.
exec gh codespace ssh -c "$name" -- \
  "$REMOTE_PYTHON" "$REMOTE_SERVER"
