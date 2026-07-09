# dotfiles

If you are reading this, welcome. These are my dotfiles intended for Codespaces. I hate configuring stuff, so if you are referencing these, proceed with caution. It's all vibe coded 

## Layout

| Path | What |
|------|------|
| `install.sh` | Idempotent installer (nvim + terminfo + shell wiring + tmux MCP venv). |
| `bin/` | Standalone scripts. `tmux-mcp-server.py` — MCP server for remote tmux control (see below). |
| `nvim/` | Neovim config — `init.lua` + `lua/plugins/*` (lazy.nvim). |
| `.sharedrc.append` | Aliases + functions sourced in **both** bash and zsh. |
| `.zshrc.append` / `.bashrc.append` | Shell-specific extras. |
| `ghostty.terminfo` | Ghostty terminfo source, compiled with `tic` on install. |

## Handy shell helpers

Defined in `.sharedrc.append` (sourced in both bash and zsh).

### Functions

- **`reload_dotfiles`** — pull the latest and re-run the installer (updates nvim config + plugins, and recompiles treesitter parsers so they stay in sync with the nvim ABI after an upgrade), then re-source the current shell's rc so new aliases/functions are picked up immediately.
- **`claude_worktree [-a|-d|-b|--base|--delete] [--force] [id]`** (aliased to **`cwt`**) — start a background tmux session (`<prefix>-<id>`, id defaults to `0`) running `claude --worktree`. Because tmux runs on the box, the session survives SSH disconnects. The prefix is `tmux-claude`, or — inside a Codespace — the codespace name with its trailing random segment stripped.
  - `cwt [-a|-d] [id]` — create session `<prefix>-id`; `-a` attach (default), `-d` background.
  - `cwt [-a|-d] id -b|--base base_id` — create session `<prefix>-id` but run claude inside the **existing** worktree `<prefix>-base_id` instead of creating a new one; errors if that worktree doesn't exist. `-b` is an option (takes the base worktree id) and combines with `-a`/`-d` in any order, e.g. `cwt -d 2 -b 1` backgrounds session `<prefix>-2` running claude in worktree `<prefix>-1`.
  - `cwt cd id` — cd into `<prefix>-id`'s worktree dir (id required, must exist).
  - `cwt cd -` — cd back to the main worktree.
  - `cwt ls` — list this prefix's sessions/worktrees as a table (`ID`, `SESSION` live/`-`, `WORKTREE` path/`-`), merging live tmux sessions and on-disk worktrees.
  - `cwt --delete [--force] id` — kill `<prefix>-id` and prune its worktree (`--force` discards uncommitted changes; id required).
  - `cwt -h` / `--help` — show usage.

### Aliases

| Alias | Runs | What |
|-------|------|------|
| `start_rxn` | `(cd src/frontend/reactNativeApp && pnpm start)` | Start the React Native Metro bundler (in a subshell, so your cwd is unchanged). |
| `preload_rxn` | `curl … /index.bundle?platform=ios…` | Warm the Metro cache by fetching the iOS JS bundle once, so the first app launch isn't slow. |
| `makeschemas` | `m generate_api_schemas && (cd src/frontend/rsdk && pnpm run build:apiClient)` | Regenerate API schemas (`m` = manage.py wrapper), then rebuild the typed frontend API client. |
| `followlogs` | `dc logs -f -n 20` | Tail the docker-compose container logs (last 20 lines, then follow). |
| `fetchandreset` | `git fetch && git reset --hard origin/master` | **Destructive.** Discard all local commits/changes and match `origin/master` exactly. |
| `restartcontainers` | `dc down && dc up -d` | Recreate the docker-compose stack (down, then up in the background). |
| `msp` | `m shell_plus` | Open the Django `shell_plus` REPL. |
| `staging` | `k9s --context staging-a` | Open k9s (terminal Kubernetes UI) on the `staging-a` cluster. |

`m` and `dc` are project shell wrappers (manage.py and docker-compose respectively), available in the Codespace.

## Remote tmux control (MCP)

Drive the codespace's tmux sessions — including the `claude` sessions `cwt`
creates — from Claude Code running on the laptop, over an MCP server.

**How it works.** The MCP server (`bin/tmux-mcp-server.py`, FastMCP) runs *on*
the codespace and is a thin, stateless shim: every tool just shells out to
`tmux`, so all state stays in the tmux server. Claude Code on the laptop spawns
it per-connection over `gh codespace ssh` (stdio transport) — no forwarded
ports, no long-lived daemon, and it reuses GitHub's existing SSH auth. Because
state lives in tmux, it sees the same `<prefix>-<id>` sessions `cwt` manages,
and two clients spawning separate server processes stay consistent.

**Setup.**

1. On the codespace, `install.sh` provisions an isolated venv (`~/.tmux-mcp-venv`)
   with the `mcp` SDK — kept separate so it never fights the monorepo's Python
   env. This runs on first install; re-runs skip it.
2. On the laptop, run `tmc` (function `tmux_mcp`, defined in `.zshrc.local`).
   It picks a codespace interactively and registers the server with Claude Code
   at user scope, then run `/mcp` inside Claude Code to connect.
   - `tmc` — pick a codespace and (re)register the MCP server (re-run to
     re-point at a different codespace).
   - `tmc -d` — remove the registered MCP server.
   - `tmc -h` / `--help` — show usage.

**Tools exposed:** `list_sessions`, `new_session` (optionally running `claude`
or an arbitrary command), `send_keys`, `capture_output` (line-capped so a long
Claude run can't dump megabytes over SSH), `kill_session`.

## Updating

```bash
reload_dotfiles
```
