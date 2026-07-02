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

Defined in `.sharedrc.append`:

- **`reload_dotfiles`** — pull the latest and re-run the installer (updates nvim config + plugins).
- **`claude_worktree [-a|-d|--delete] [--force] [id]`** (aliased to **`cwt`**) — start a background tmux session (`tmux-claude-<id>`, id defaults to `0`) running `claude --worktree`. Because tmux runs on the box, the session survives SSH disconnects.
  - `cwt [-a|-d] [id]` — create session `<prefix>-id`; `-a` attach (default), `-d` background.
  - `cwt cd id` — cd into `<prefix>-id`'s worktree dir (id required, must exist).
  - `cwt cd -` — cd back to the main worktree.
  - `cwt --delete [--force] id` — kill `<prefix>-id` and prune its worktree (`--force` discards uncommitted changes; id required).
  - `cwt -h` / `--help` — show usage.

## Updating

```bash
reload_dotfiles
```
