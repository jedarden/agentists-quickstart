#!/usr/bin/env bash
# start.sh — launches a Claude Code session inside herdr. Run bootstrap.sh
# first. Safe to run repeatedly: from a plain terminal it launches/attaches
# herdr; inside a herdr-managed pane it launches claude directly.
set -euo pipefail

if [[ -n "${HERDR_ENV:-}" ]]; then
    # Already inside a herdr-managed pane (herdr sets this for every pane it
    # spawns, including the one this triggers when run from a plain terminal
    # below) — just run claude.
    unset CLAUDECODE
    # herdr's server is a detached, long-lived process that may itself have
    # been launched from inside a Claude Code session; if so its env (and
    # every pane it spawns) carries a stale CLAUDE_CODE_CHILD_SESSION marker.
    # Left set, the claude process below wrongly believes it's a nested
    # session and disables transcript saving, breaking --resume.
    unset CLAUDE_CODE_CHILD_SESSION
    exec claude --dangerously-skip-permissions --model sonnet
fi

command -v herdr &>/dev/null || {
    echo "herdr not found — run bootstrap.sh first." >&2
    exit 1
}

# Protect the herdr server from the OOM killer: on memory exhaustion the
# kernel should kill a single agent pane, not the server (which takes every
# pane down at once). Needs the passwordless-sudo rule bootstrap.sh installs.
SERVER_PID="$(pgrep -f '^herdr server$' | head -1 || true)"
if [[ -n "$SERVER_PID" ]]; then
    if sudo -n choom -n -1000 -p "$SERVER_PID" &>/dev/null; then
        echo "Protected herdr server (pid $SERVER_PID) from OOM killer."
    else
        echo "Warning: could not set OOM protection on herdr server (needs passwordless sudo + choom — see bootstrap.sh)."
    fi
fi

# Not yet in herdr — launch/attach it. The pane herdr creates for this gets
# HERDR_ENV set, and bootstrap.sh's ~/.bashrc hook re-execs this script in
# that pane, hitting the branch above and launching claude automatically.
exec herdr
