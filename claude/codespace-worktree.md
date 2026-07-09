# Codespace: worktrees vs. /workspaces/web

This codespace has **one** dev environment — the Docker stack, database, and
dev-server ports are all bound to `/workspaces/web`. Read these rules before you
run anything.

## The app only runs at /workspaces/web

- The running webapp, the Docker stack, and the project aliases (`m`, `dc`, `t`,
  and friends) all operate against **`/workspaces/web`** — never against a
  worktree. An alias run from a worktree still targets `/workspaces/web`, so its
  output does **not** reflect the worktree's code.
- Git worktrees under `/workspaces/web/.claude/worktrees/<name>` are for
  **editing code only**. You cannot start the site or meaningfully exercise the
  running app from a worktree.

## If you're working in a worktree

You're in a worktree when your cwd is under `.claude/worktrees/`. In that case:

- **Do not** start the site or run project/dev commands (`m`, `dc`, `t`, `yarn`,
  `pnpm`, and other build/lint/test wrappers) to verify your change — they won't
  reflect your code and can disrupt the shared environment.
- Verify by **committing and relying on CI**, or by **asking the user** to run
  it for you.
- **Never** take over `/workspaces/web` on your own. Several agents share this
  one codespace and only one can use `/workspaces/web` at a time — assume others
  are working right now.

## Running a worktree's code in /workspaces/web (only with the user's OK)

Sometimes a change genuinely has to be run live. Because `/workspaces/web` is
shared and this overlay rewrites its working tree, **do it only after the user
confirms `/workspaces/web` is free to use.** Then:

1. **Commit your work in the worktree.** The overlay below moves only committed
   files; uncommitted edits won't come across.
2. **Make sure `/workspaces/web` is clean first.** Whatever is checked out there
   will be discarded by the overlay and the revert — stash or commit it, and ask
   the user if you're unsure it's safe to disturb.
3. **Overlay your branch's files:**
   ```
   cd /workspaces/web
   git checkout <your-branch> -- .
   ```
   Git won't let the same branch be checked out in two places, so you can't just
   `switch` to it here. This pathspec form copies your branch's committed files
   onto `/workspaces/web`'s working tree while it stays on its own branch.
4. **Run and verify** (`m …`, `dc …`, start the site, etc.).
5. **Revert and hand it back the moment you're done:**
   ```
   git reset --hard HEAD
   ```
   (Safe because step 2 left `/workspaces/web` clean — this just drops the
   overlay. Add `git clean -fd` only if the run created new untracked files you
   want gone.) Leaving `/workspaces/web` overlaid blocks every other agent.

Caveats: the overlay does **not** delete files your branch removed, and does not
include uncommitted changes. If exact fidelity matters, tell the user instead of
guessing.
