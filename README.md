# dotfiles

If you are reading this, welcome. These are my dotfiles for hosted dev boxes — GitHub Codespaces and Coder workspaces — and plain local machines. I hate configuring stuff, so if you are referencing these, proceed with caution. It's all vibe coded 

## Layout

| Path | What |
|------|------|
| `install.sh` | Idempotent installer (nvim + terminfo + shell wiring + Claude memory + `rover-vault` clone). Resolves the checkout from its own location, so it runs on any box. On a dev box it also symlinks in the worktree/run guidance (`codespace-worktree.md`, which lives in the synced `claude-settings` repo) and `@import`s it into `~/.claude/CLAUDE.md`. |
| `nvim/` | Neovim config — `init.lua` + `lua/plugins/*` (lazy.nvim). |
| `.sharedrc.append` | Aliases + functions sourced in **both** bash and zsh. |
| `.zshrc.append` / `.bashrc.append` | Shell-specific extras. |
| `ghostty.terminfo` | Ghostty terminfo source, compiled with `tic` on install. |

## Handy shell helpers

Defined in `.sharedrc.append` (sourced in both bash and zsh).

### Functions

- **`reload_dotfiles [-f|--force]`** — pull the latest and re-run the installer (updates nvim config + plugins, and recompiles treesitter parsers so they stay in sync with the nvim ABI after an upgrade), then re-source the current shell's rc so new aliases/functions are picked up immediately. Pass `-f`/`--force` to discard unstaged changes to tracked files first (`git reset --hard`) when the box's checkout has local edits blocking the pull.

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
