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

### Shell command help text

Shell helpers live in `.sharedrc.append` (sourced in both bash and zsh). When a command grows a `-h`/`--help` block or you change what that help prints:

- **Mirror the help text into `README.md`.** The "Handy shell helpers" section of the README must match the command's built-in help. If you add a subcommand or flag to a command's `--help`, add the same line to the README so the two never drift.

### Inline comments

The repo owner is not a config expert. Any Neovim config or shell script you add or change must be commented so a non-expert can follow it:

- **Explain the why, not just the what.** Say what a setting/keymap/function does and why it's there, in plain language. Assume the reader doesn't know the plugin's or shell's conventions.
- **Comment non-obvious syntax.** Lua/vimscript idioms, shell parameter expansions (`${1:-0}`, `${VAR%-*}`), `git` plumbing flags, and any clever one-liner get a short explanation.
- Match the surrounding comment style (the existing files already comment heavily — keep that density).

## Layout

See `README.md` for the file layout table. `install.sh` is the idempotent installer — keep it idempotent (guard every append with a marker check on the file being appended to).
