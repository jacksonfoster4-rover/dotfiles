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

import shutil
import subprocess
from typing import Optional

from mcp.server.fastmcp import FastMCP

mcp = FastMCP("codespace-tmux")

# Hard cap on captured lines so a long Claude run can't return megabytes back
# over the SSH pipe (see design doc: "Output size limits").
MAX_CAPTURE_LINES = 2000


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
def new_session(name: str, command: Optional[str] = None, run_claude: bool = False) -> str:
    """Create a new detached tmux session named `name`.

    - command: shell command the session runs (e.g. "claude --worktree foo -n foo").
    - run_claude: convenience to start plain `claude`; ignored when `command` is set.

    To reproduce a `cwt` session, pass command="claude --worktree <name> -n <name>".
    Errors if a session with that name already exists.
    """
    if _session_exists(name):
        raise TmuxError(f"session {name!r} already exists")
    run = command if command else ("claude" if run_claude else None)
    argv = ["new-session", "-d", "-s", name]
    if run:
        argv.append(run)
    _tmux(*argv)
    return f"created session {name!r}" + (f" running: {run}" if run else "")


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
