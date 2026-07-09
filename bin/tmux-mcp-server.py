#!/usr/bin/env python3
"""MCP server exposing tmux session control on this codespace.

Runs ON the codespace, spawned per-connection by a local MCP client over
`gh codespace ssh -- <venv-python> <this-file>` (stdio transport). It is a thin,
stateless shim: all real state lives in the tmux server, so each tool just shells
out to `tmux`. Because of that it transparently sees and controls the sessions
the `cwt` (claude_worktree) helper creates -- those are ordinary tmux sessions
named "<prefix>-<id>". Two clients spawning separate server processes still see
the same sessions, so concurrent use is safe by construction.

Tool surface mirrors the session-manager operations: list / create / send-keys /
capture / kill.
"""
from __future__ import annotations

import os
import shutil
import subprocess
import time
from typing import Optional

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("codespace-tmux")

# Hard cap on captured lines so a long Claude run can't return megabytes back
# over the SSH pipe (see design doc: "Output size limits").
MAX_CAPTURE_LINES = 2000

# New sessions start here by default -- the web repo root on the codespace -- so
# a `claude` started remotely lands in the project, not the SSH login home dir.
WEB_DIR = "/workspaces/web"


class TmuxError(RuntimeError):
    """Raised when a tmux command exits non-zero; message carries stderr.

    FastMCP turns a raised exception into a structured tool error for the
    client, so this is how we return failures instead of handing back empty or
    partial stdout (see design doc: "Error handling").
    """


def _tmux(*args: str) -> str:
    """Run `tmux <args>`, returning stdout and raising TmuxError on failure."""
    if shutil.which("tmux") is None:
        raise TmuxError("tmux is not installed / not on PATH on this codespace")
    proc = subprocess.run(["tmux", *args], capture_output=True, text=True)
    if proc.returncode != 0:
        # tmux writes "no server running" / "can't find session" to stderr.
        raise TmuxError(
            proc.stderr.strip() or f"tmux {' '.join(args)} failed (rc={proc.returncode})"
        )
    return proc.stdout


def _session_exists(name: str) -> bool:
    """True if a tmux session named `name` is currently live."""
    try:
        _tmux("has-session", "-t", name)
        return True
    except TmuxError:
        return False


def _session_prefix() -> str:
    """The session-name prefix, matching `cwt`: inside a Codespace, the codespace
    name with its trailing random segment stripped (CODESPACE_NAME up to its last
    "-"); otherwise "tmux-claude". Keeps MCP-created sessions in the same
    namespace as hand-created cwt ones, so they group together and show in `cwt ls`.
    """
    cs = os.environ.get("CODESPACE_NAME")
    if cs:
        return cs.rsplit("-", 1)[0]
    return "tmux-claude"


def _wait_for_ui(session: str, timeout: float) -> bool:
    """Wait until `session`'s pane stops changing, i.e. Claude's TUI finished its
    initial draw, so keystrokes sent next aren't dropped mid-boot.

    Version-agnostic on purpose: rather than matching specific TUI strings (which
    change between Claude releases), it waits for two consecutive identical,
    non-empty captures. A fresh Claude prompt is static until you submit, so it
    settles quickly; the animated "thinking" spinner only appears afterward.
    Returns True once stable, False if `timeout` seconds elapse first.
    """
    deadline = time.monotonic() + timeout
    prev = None
    while time.monotonic() < deadline:
        try:
            pane = _tmux("capture-pane", "-t", session, "-p").strip()
        except TmuxError:
            return False
        if pane and pane == prev:
            return True
        prev = pane
        time.sleep(0.6)
    return False


@mcp.tool()
def list_sessions() -> list[dict]:
    """List tmux sessions with window count, working directory, and attach state.

    Returns an empty list when no tmux server is running (i.e. zero sessions)
    rather than erroring, so "nothing running" reads as normal.
    """
    fmt = (
        "#{session_name}\t#{session_windows}\t#{pane_current_path}"
        "\t#{?session_attached,attached,detached}"
    )
    try:
        out = _tmux("list-sessions", "-F", fmt)
    except TmuxError as e:
        # "no server running on ..." just means there are no sessions yet.
        if "no server running" in str(e).lower():
            return []
        raise
    sessions = []
    for line in out.splitlines():
        if not line.strip():
            continue
        # Pad so a missing trailing field (e.g. empty path) never IndexErrors.
        name, windows, path, state = (line.split("\t") + ["", "", "", ""])[:4]
        sessions.append(
            {
                "name": name,
                "windows": int(windows) if windows.isdigit() else 0,
                "path": path,
                "state": state,
            }
        )
    return sessions


@mcp.tool()
def new_session(
    name: str,
    command: Optional[str] = None,
    run_claude: bool = False,
    cwd: Optional[str] = None,
) -> str:
    """Create a new detached tmux session named `name`.

    - command: shell command the session runs (e.g. "claude --worktree foo -n foo").
    - run_claude: convenience to start plain `claude`; ignored when `command` is set.
    - cwd: working directory the session starts in (default: the web repo root,
      /workspaces/web), so a remotely-started `claude` lands in the project.

    To reproduce a `cwt` session, pass command="claude --worktree <name> -n <name>".
    Errors if a session with that name already exists.
    """
    if _session_exists(name):
        raise TmuxError(f"session {name!r} already exists")
    run = command if command else ("claude" if run_claude else None)
    start_dir = cwd or WEB_DIR
    argv = ["new-session", "-d", "-s", name, "-c", start_dir]
    if run:
        argv.append(run)
    _tmux(*argv)
    return f"created session {name!r} in {start_dir}" + (f" running: {run}" if run else "")


@mcp.tool()
def start_claude_task(
    session_id: str,
    prompt: str,
    worktree: bool = True,
    cwd: Optional[str] = None,
    timeout: float = 40.0,
) -> str:
    """Launch a Claude Code session and hand it `prompt` to work on.

    One call for the common orchestration case: create the session, wait for
    Claude's UI to finish drawing, then type the task in. The prompt is delivered
    via send-keys (not baked into the launch command) so multi-line ticket text
    needs no shell quoting.

    - session_id: short id for the task (e.g. a Jira ticket number "14301"). The
      full session + worktree name is "<prefix>-<session_id>" following the `cwt`
      convention, so it groups with cwt's sessions and appears in `cwt ls`.
    - prompt: the task text (e.g. a Jira ticket's title + description + ACs).
    - worktree: True -> `claude --worktree <name>` so the task gets its own
      isolated worktree/branch; False -> plain `claude` in `cwd`.
    - cwd: starting dir (default /workspaces/web).
    - timeout: seconds to wait for the UI before typing the prompt.

    Errors if that session already exists.
    """
    name = f"{_session_prefix()}-{session_id}"
    if _session_exists(name):
        raise TmuxError(f"session {name!r} already exists")
    start_dir = cwd or WEB_DIR
    # Mirror the `cwt` launch so these sessions match hand-created ones.
    run = f"claude --worktree {name} -n {name}" if worktree else "claude"
    _tmux("new-session", "-d", "-s", name, "-c", start_dir, run)
    ready = _wait_for_ui(name, timeout)
    _tmux("send-keys", "-t", name, prompt)
    _tmux("send-keys", "-t", name, "Enter")
    where = f"worktree {name}" if worktree else start_dir
    if not ready:
        return (
            f"started {name!r} ({where}) and sent the task, but Claude's UI wasn't "
            f"visibly ready within {timeout:g}s — if the prompt didn't land, "
            f"capture_output to check and resend with send_keys"
        )
    return f"started {name!r} ({where}) and sent the task"


@mcp.tool()
def send_keys(session: str, keys: str, enter: bool = True) -> str:
    """Send `keys` to `session`, pressing Enter afterward unless enter=False.

    `keys` is sent as a single tmux key argument, so plain text (including
    spaces) is typed literally, while tmux key names work too (e.g. "C-c",
    "Escape"). Use enter=False to type without submitting, or to send a control
    sequence on its own.
    """
    if not _session_exists(session):
        raise TmuxError(f"no such session: {session!r}")
    _tmux("send-keys", "-t", session, keys)
    if enter:
        _tmux("send-keys", "-t", session, "Enter")
    return f"sent to {session!r}" + (" + Enter" if enter else "")


@mcp.tool()
def capture_output(session: str, lines: int = 50) -> str:
    """Capture the last `lines` lines of visible + scrollback output from `session`.

    `lines` is clamped to [1, MAX_CAPTURE_LINES] so a long-running Claude
    session can't dump megabytes back over SSH.
    """
    if not _session_exists(session):
        raise TmuxError(f"no such session: {session!r}")
    lines = max(1, min(int(lines), MAX_CAPTURE_LINES))
    # -p prints the pane to stdout; -S -<N> starts <N> lines up the scrollback.
    return _tmux("capture-pane", "-t", session, "-p", "-S", f"-{lines}")


@mcp.tool()
def kill_session(session: str) -> str:
    """Kill `session`.

    Does NOT prune any git worktree a `cwt` session created -- run
    `cwt --delete <id>` on the codespace for that.
    """
    if not _session_exists(session):
        raise TmuxError(f"no such session: {session!r}")
    _tmux("kill-session", "-t", session)
    return f"killed {session!r}"


if __name__ == "__main__":
    mcp.run()  # defaults to stdio transport
