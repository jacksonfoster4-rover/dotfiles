# dotfiles

If you are reading this, welcome. These are my dotfiles intended for Codespaces. I hate configuring stuff, so if you are referencing these, proceed with caution. It's all vibe coded 

## Layout

| Path | What |
|------|------|
| `install.sh` | Idempotent installer (nvim + terminfo + shell wiring + tmux MCP venv + Claude memory). |
| `bin/` | Standalone scripts. `tmux-mcp-server.py` — MCP server for remote tmux control (see below). |
| `claude/` | Claude Code guidance imported into the codespace's `~/.claude/CLAUDE.md`. `codespace-worktree.md` — worktree vs. `/workspaces/web` run rules. |
| `nvim/` | Neovim config — `init.lua` + `lua/plugins/*` (lazy.nvim). |
| `.sharedrc.append` | Aliases + functions sourced in **both** bash and zsh. |
| `.zshrc.append` / `.bashrc.append` | Shell-specific extras. |
| `ghostty.terminfo` | Ghostty terminfo source, compiled with `tic` on install. |

## Handy shell helpers

Defined in `.sharedrc.append` (sourced in both bash and zsh).

### Functions

- **`reload_dotfiles [-f|--force]`** — pull the latest and re-run the installer (updates nvim config + plugins, and recompiles treesitter parsers so they stay in sync with the nvim ABI after an upgrade), then re-source the current shell's rc so new aliases/functions are picked up immediately. Pass `-f`/`--force` to discard unstaged changes to tracked files first (`git reset --hard`) when the box's checkout has local edits blocking the pull.
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
creates — from a Claude client on the laptop (Claude Code or Claude Desktop),
over an MCP server. This is what lets you, e.g., open Claude Desktop, have it
pull a Jira ticket, and tell it to spin up a `claude` session on the codespace
to implement it — all without touching the terminal or VSCode.

**How it works.** The MCP server (`bin/tmux-mcp-server.py`, FastMCP) runs *on*
the codespace and is a thin, stateless shim: every tool just shells out to
`tmux`, so all state stays in the tmux server. The laptop client spawns it
per-connection over `gh codespace ssh` (stdio transport) — no forwarded ports,
no long-lived daemon, and it reuses GitHub's existing SSH auth. Because state
lives in tmux, it sees the same `<prefix>-<id>` sessions `cwt` manages, and two
clients spawning separate server processes stay consistent.

**Setup.**

1. On the codespace, `install.sh` provisions an isolated venv (`~/.tmux-mcp-venv`)
   with the `mcp` SDK — kept separate so it never fights the monorepo's Python
   env. This runs on first install; re-runs skip it.
2. On the laptop, run `tmc` (function `tmux_mcp`, defined in `.zshrc.local`).
   It picks a codespace interactively and registers the server. If the chosen
   codespace is stopped, `tmc` starts it and waits until it's reachable first
   (there's no `gh codespace start` — SSHing in is what boots it), so the first
   connection isn't stuck waiting on a cold box.
   - `tmc` — (re)register with the Claude Code CLI (user scope), then run `/mcp`
     inside Claude Code to connect. Re-run to re-point at a different codespace.
   - `tmc --desktop` — write the server into Claude Desktop's config (the
     codespace name is baked in, since Desktop can't run the picker), then
     restart Claude Desktop to pick it up.
   - `tmc -d` — remove the Claude Code registration.
   - `tmc -h` / `--help` — show usage.

**Tools exposed:** `list_sessions`; `new_session` (optionally running `claude`
or an arbitrary command); `start_claude_task` (one call to create a session,
wait for Claude's UI, and type in a task — the orchestration primitive for
"implement this ticket", worktree-isolated by default, named `<prefix>-<id>`
like `cwt` so it shows up in `cwt ls`); `send_keys`;
`capture_output` (line-capped so a long Claude run can't dump megabytes over
SSH); `kill_session`.

**Note on running the code.** Sessions default to running inside their own git
worktree, which is great for parallel isolation but *cannot run the site or
project aliases* — only `/workspaces/web` can (see `claude/codespace-worktree.md`,
imported into the codespace's `~/.claude/CLAUDE.md`). Agents verify via CI or ask
before running in the shared `/workspaces/web`.

## Updating

```bash
reload_dotfiles
```
