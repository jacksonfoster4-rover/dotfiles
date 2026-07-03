# CLAUDE.md

Guidance for Claude Code when working in this dotfiles repo.

## Documentation rules

These are non-negotiable. Any change that adds or alters user-facing behavior must update the matching docs in the same change.

### Neovim changes

Neovim config lives in `nvim/` (keymaps in `nvim/lua/keymaps.lua`, plugins in `nvim/lua/plugins/*`). The help doc is `nvim/doc/jwf.txt`, viewable in-editor with `:help jwf`.

When you add, remove, or change a keymap, command, or plugin behavior:

- **Document it in the `jwf.txt` help text.** Add or update the relevant detailed section (e.g. `*jwf-ai*`, `*jwf-git*`, `*jwf-tmux*`) and its `*jwf-contents*` entry / `doc/tags` if you add a new section tag.
- **Add a quick-help entry too.** The `*jwf-quick*` section at the top of `jwf.txt` is the everyday cheat sheet — if the mapping is something you'd actually reach for, it belongs there in addition to its detailed section. Keep the quick entry to one line.

Don't document a keymap only in the detailed section and skip the quick reference (or vice versa) — both get updated.

### Shell helpers (`.sharedrc.append`)

Shell helpers live in `.sharedrc.append` (sourced in both bash and zsh). Keep `.sharedrc.append` itself lightly commented — **document the helpers in `README.md`, not with inline alias comments.** The "Handy shell helpers" section of the README is the source of truth:

- **New alias** → add a row to the README "Aliases" table (alias, what it runs, plain-language description). Don't add an explanatory comment above the alias in `.sharedrc.append`.
- **New/changed function** → add or update its entry under README "Functions".
- **A command's `-h`/`--help` block changes** → mirror the same lines into the README so the two never drift.

Inline comments in `.sharedrc.append` are reserved for non-obvious *logic* inside functions (shell parameter expansions like `${1:-0}` / `${VAR%-*}`, `git` plumbing flags, clever one-liners) — the repo owner is not a config expert, so explain those where they appear. Plain aliases get documented in the README instead.

#### `claude_worktree` is mirrored to a public gist

The `claude_worktree` function (alias `cwt`) is shared with teammates via a public GitHub gist: https://gist.github.com/jacksonfoster4-rover/a284d137c51304fdc4e1e255bb65ed34

**Whenever you change the `claude_worktree` function in `.sharedrc.append`, update the gist too** so teammates who `curl` it get the new version. Update it with `gh`:

```sh
gh gist edit a284d137c51304fdc4e1e255bb65ed34 -a claude_worktree.sh <file>
```

where `<file>` is the standalone copy — the `claude_worktree` block (the comment header through the `alias cwt=...` line) extracted from `.sharedrc.append`. This requires the user's approval for the public upload; ask before running it.

### Neovim inline comments

The repo owner is not a config expert. Any Neovim config you add or change must be commented so a non-expert can follow it: explain the why, not just the what, and gloss non-obvious Lua/vimscript idioms. Match the surrounding comment density (the existing files comment heavily).

## Layout

See `README.md` for the file layout table. `install.sh` is the idempotent installer — keep it idempotent (guard every append with a marker check on the file being appended to).
