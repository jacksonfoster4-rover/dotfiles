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
  - `claude_worktree 2` — create if needed and attach to `tmux-claude-2` (`-a` is the default).
  - `claude_worktree -d 2` — create in the background, don't attach.
  - `claude_worktree --delete 2` — kill the session and prune its git worktree (`--force` to discard uncommitted changes).

## Updating

```bash
reload_dotfiles
```
