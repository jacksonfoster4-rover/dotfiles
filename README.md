# dotfiles

If you are reading this, welcome. These are my dotfiles for Coder workspaces (Roverspaces) and my laptop. I hate configuring stuff, so if you are referencing these, proceed with caution. It's all vibe coded 

## Layout

| Path | What |
|------|------|
| `install.sh` | Idempotent installer (nvim + terminfo + shell wiring + Claude memory + `rover-vault` clone). Resolves the checkout from its own location, so it runs on any box. On a dev box it also symlinks in the worktree/run guidance (`codespace-worktree.md`, which lives in the synced `claude-settings` repo) and `@import`s it into `~/.claude/CLAUDE.md`. On a Coder workspace with the `CDR_SESSION_TOKEN` Coder secret, it calls Coder's in-cluster address (skipping Cloudflare Access) and sets the workspace schedule to start at 8am and stop at 7pm Pacific, Mon–Fri. |
| `nvim/` | Neovim config — `init.lua` + `lua/plugins/*` (lazy.nvim). |
| `.sharedrc.append` | Aliases + functions sourced in **both** bash and zsh. |
| `.zshrc.append` / `.bashrc.append` | Shell-specific extras. Each sources `.sharedrc.append` relative to its own location; `install.sh` hooks them into `~/.zshrc` / `~/.bashrc`. |
| `.zshrc.local` | Laptop-only zsh helpers, sourced from the laptop's `~/.zshrc`. Not installed on workspaces. |
| `ghostty.terminfo` | Ghostty terminfo source, compiled with `tic` on install. |

## Handy shell helpers

Defined in `.sharedrc.append` (sourced in both bash and zsh).

### Functions

- **`reload_dotfiles [-f|--force]`** — pull the latest and re-run the installer (updates nvim config + plugins, and recompiles treesitter parsers so they stay in sync with the nvim ABI after an upgrade), then re-source the current shell's rc so new aliases/functions are picked up immediately. Pass `-f`/`--force` to discard unstaged changes to tracked files first (`git reset --hard`) when the box's checkout has local edits blocking the pull.
- **`review [base]`** — open [difit](https://github.com/yoshiko-pg/difit) (a GitHub-style diff viewer with inline comments) for the current branch against `base` (default `origin/master`), diffed from the merge base. Fetches the base first, serves on port 4966, and prints the URL to open (the Coder forwarded host on a workspace, `localhost` elsewhere). Ctrl-C stops it.

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

## Laptop helpers

Defined in `.zshrc.local` (laptop only).

### Functions

- **`upload_ssh [workspace]`** — copy `~/.ssh/id_rsa` and `id_rsa.pub` into a Coder workspace's devcontainer (`<workspace>.dev`), so git over SSH works there. With no argument it picks from your running workspaces (fzf, or auto-picks if only one is running).
- **`pick_coder_workspace`** — print the name of a running Coder workspace, chosen with fzf (auto-picks when only one is running). Used by `upload_ssh`.
- **`killport <port>`** — kill whatever is listening on a TCP port.

### Aliases

| Alias | Runs | What |
|-------|------|------|
| `local_setup` | `~/projects/web/dev-env/local-setup/dist/local-setup.sh` | Run the web repo's local setup script. |
| `reload_nvim` | `rm -rf ~/.local/share/nvim ~/.config/nvim && cp -r ~/projects/dotfiles/nvim ~/.config` | Wipe nvim's plugin data and config, then copy in a fresh config from this repo. |
| `staging` | `k9s --context staging-a` | Same as the shared alias, for the laptop. |

## Updating

```bash
reload_dotfiles
```

Workspaces set up before the `.zshrc.append` / `.bashrc.append` fix have local edits to those files (the old installer appended to them), which block the pull. Run `reload_dotfiles -f` once on each.
