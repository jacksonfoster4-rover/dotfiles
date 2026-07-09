# Codespace tmux control (MCP)

Drive the tmux sessions on your Codespace — including the `claude` sessions
`cwt` starts — from a Claude client on your laptop. The whole point: kick off and
babysit work on the box without opening a terminal or VSCode.

An MCP server runs *on* the Codespace and just shells out to `tmux` (all state
lives in tmux, so it's a stateless shim). Your laptop's Claude client spawns it
per-connection over `gh codespace ssh`. Because it's talking to the real tmux
server, it sees the same `<prefix>-<id>` sessions `cwt` creates.

## Setup

**Once, on the Codespace:**

```
reload_dotfiles     # builds the MCP venv + installs the CLAUDE.md guidance
```

**Once per client, on the laptop:**

```
tmc                 # register with Claude Code CLI, then run /mcp to connect
tmc --desktop       # write it into Claude Desktop's config, then restart Desktop
```

`tmc` picks a Codespace interactively and **starts it if it's stopped** (waits
until it's reachable, so the first connection isn't a cold-start timeout). Re-run
`tmc` to re-point at a different Codespace. `tmc -d` removes the Claude Code
registration; `tmc -h` shows usage.

## What Claude can do once connected

| Tool | What it does |
|------|--------------|
| `list_sessions` | List sessions (name, window count, cwd, attached?). |
| `start_claude_task` | Create a session, wait for Claude's UI, and type in a task. The "go implement this" primitive. Worktree-isolated by default. Names the session `<prefix>-<id>` like `cwt`, so it shows up in `cwt ls`. |
| `new_session` | Create a bare session, optionally running `claude` or any command. |
| `send_keys` | Type into a session (steer a running Claude, answer a prompt). |
| `capture_output` | Read the last N lines of a session's screen. |
| `kill_session` | Kill a session. |

## Workflow: two tickets, start to finish

Say you've got **DEV-14301** and **DEV-14302**. Setup's already done. You open
**Claude Desktop** — no terminal, no VSCode. *(The ticket fetch needs an
Atlassian MCP in Desktop.)*

**1. Kick both off.**

> **You:** "Grab DEV-14301 and DEV-14302 from Jira and start each one on my
> codespace in its own worktree."

Per ticket, Claude fetches it (Atlassian MCP) and calls
`start_claude_task(session_id="14301", prompt="<the ticket>")`. You get two
sessions back — `glorious-xylophone-14301` and `glorious-xylophone-14302` — each
a `claude` running in its own worktree. Two workers are now grinding, isolated
from each other.

**2. Go do something else, then check in.**

> **You:** "How are they doing?"

Claude calls `capture_output` on both: *"14301 edited the serializer + added a
test, looks done and waiting. 14302 is asking whether to also cover the null
case."*

**3. Steer the one that's stuck.**

> **You:** "Tell 14302 yes, handle the null case too."

Claude calls `send_keys("glorious-xylophone-14302", "Yes, handle the null case
as well")`. It keeps going.

**4. Verify — where the `/workspaces/web` rule bites.**

14301 is in a worktree, so it *can't* run `m test` or start the site. It commits
and pushes; **CI** runs the tests. If you want it exercised live, Claude asks
first — because `/workspaces/web` is shared — then does the git-overlay dance
(commit → `git checkout <branch> -- .` in `/workspaces/web` → run →
`git reset --hard HEAD`).

**5. Wrap up.**

> **You:** "Push 14302's branch and kill both sessions."

Claude `send_keys` the push, then `kill_session` on both. Prune the worktrees
later on the box with `cwt --delete 14301` / `14302`.

The shape: **you talk to one Claude (Desktop); it fans work out to N worker
Claudes on the codespace, each isolated, and you supervise them all from chat.**
Because the sessions use cwt's naming, `cwt ls` on the box lists them right
alongside any you started by hand.

### Driving from the CLI instead

Same tools, from Claude Code on the laptop (`tmc`). Claude Code can *also* run
`gh`/`git` directly, so use whichever's handier — the MCP server is only needed
to reach the Codespace's tmux state (and it's the *only* option from Desktop).

## The one rule that bites: running the code

Worker sessions default to their own **git worktree** (`.claude/worktrees/<name>`).
Great for parallel isolation — but a worktree **cannot start the site or run
`m`/`dc`/etc.** Only `/workspaces/web` can, and it's shared by every agent.

So a worker verifies by **committing + CI**, or by **asking you** before running
anything in `/workspaces/web`. The git-overlay procedure for an approved live run
is spelled out in `claude/codespace-worktree.md` (imported into the Codespace's
`~/.claude/CLAUDE.md`, so every agent already knows the rule).

## Gotchas

- **`capture_output` returns the rendered TUI** — spinners and box-drawing
  included. Fine for a human glance; noisy for exact parsing.
- **Idle stop.** Codespaces auto-stop after ~30 min idle. `tmc` warms the box at
  registration, but if it sleeps again the next MCP call re-starts it (slow once,
  then fine).
- **Worktree ≠ runnable.** See above — the most common source of confusion.
- **Launches go through a login shell.** `claude` lives in `~/.local/bin`, which
  is only on PATH in an interactive login shell — so `new_session`/`start_claude_task`
  run their command via `$SHELL -l -i -c`. A raw `tmux new-session <name> "claude …"`
  would exit 127 and the session would vanish the instant it's created.
- **Redeploy after editing the server.** The MCP server is baked into a venv on
  the Codespace; a laptop that edited `bin/tmux-mcp-server.py` still talks to the
  *old* copy until you re-run `reload_dotfiles` on the box (new tools like
  `start_claude_task` won't appear before that).
