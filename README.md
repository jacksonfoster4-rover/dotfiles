# dotfiles

If you are reading this, welcome. These are my dotfiles for hosted dev boxes — GitHub Codespaces and Coder workspaces — and plain local machines. I hate configuring stuff, so if you are referencing these, proceed with caution. It's all vibe coded 

## Layout

| Path | What |
|------|------|
| `install.sh` | Idempotent installer (nvim + terminfo + shell wiring + Claude memory + `rover-vault` clone). Resolves the checkout from its own location, so it runs on any box. |
| `claude/` | Claude Code guidance imported into the box's `~/.claude/CLAUDE.md`. `codespace-worktree.md` — worktree vs. `/workspaces/web` run rules. |
| `nvim/` | Neovim config — `init.lua` + `lua/plugins/*` (lazy.nvim). |
| `.sharedrc.append` | Aliases + functions sourced in **both** bash and zsh. |
| `.zshrc.append` / `.bashrc.append` | Shell-specific extras. |
| `ghostty.terminfo` | Ghostty terminfo source, compiled with `tic` on install. |

## Handy shell helpers

Defined in `.sharedrc.append` (sourced in both bash and zsh).

### Functions

- **`reload_dotfiles [-f|--force]`** — pull the latest and re-run the installer (updates nvim config + plugins, and recompiles treesitter parsers so they stay in sync with the nvim ABI after an upgrade), then re-source the current shell's rc so new aliases/functions are picked up immediately. Pass `-f`/`--force` to discard unstaged changes to tracked files first (`git reset --hard`) when the box's checkout has local edits blocking the pull.
- **`claude_worktree [-a|-d|-b|--base|--delete] [--force] [id]`** (aliased to **`cwt`**) — start a background tmux session (`<prefix>-<id>`, id defaults to `0`) running `claude --worktree`. Because tmux runs on the box, the session survives SSH disconnects. The prefix is `tmux-claude`, or — on a hosted dev box — a per-box name: the Codespace name with its trailing random segment stripped, or the Coder workspace name as-is.
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

`m` and `dc` are project shell wrappers (manage.py and docker-compose respectively), available on the dev box.

## Updating

```bash
reload_dotfiles
```
