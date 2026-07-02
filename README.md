# dotfiles

If you are reading this, welcome. These are my dotfiles intended for Codespaces. I hate configuring stuff, so if you are referencing these, proceed with caution. It's all vibe coded 

## Layout

| Path | What |
|------|------|
| `install.sh` | Idempotent installer (nvim + terminfo + shell wiring). |
| `nvim/` | Neovim config — `init.lua` + `lua/plugins/*` (lazy.nvim). |
| `.sharedrc.append` | Aliases + functions sourced in **both** bash and zsh. |
| `.zshrc.append` / `.bashrc.append` | Shell-specific extras. |
| `ghostty.terminfo` | Ghostty terminfo source, compiled with `tic` on install. |

## Handy shell helpers

Defined in `.sharedrc.append` (sourced in both bash and zsh).

### Functions

- **`reload_dotfiles`** — pull the latest and re-run the installer (updates nvim config + plugins, and recompiles treesitter parsers so they stay in sync with the nvim ABI after an upgrade), then re-source the current shell's rc so new aliases/functions are picked up immediately.
- **`claude_worktree [-a|-d|--delete] [--force] [id]`** (aliased to **`cwt`**) — start a background tmux session (`<prefix>-<id>`, id defaults to `0`) running `claude --worktree`. Because tmux runs on the box, the session survives SSH disconnects. The prefix is `tmux-claude`, or — inside a Codespace — the codespace name with its trailing random segment stripped.
  - `cwt [-a|-d] [id]` — create session `<prefix>-id`; `-a` attach (default), `-d` background.
  - `cwt cd id` — cd into `<prefix>-id`'s worktree dir (id required, must exist).
  - `cwt cd -` — cd back to the main worktree.
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

## Updating

```bash
reload_dotfiles
```
