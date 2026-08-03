#!/usr/bin/env bash
# start.sh — selects Claude Code or Codex and launches it inside herdr.
# Run bootstrap.sh first. Safe to run repeatedly.
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/agentists-quickstart"
AGENT_FILE="$STATE_DIR/selected-agent"
AGENT=""

usage() {
    cat <<'EOF'
Usage: start.sh [--agent claude|codex]
       start.sh --claude
       start.sh --codex

With no option, an interactive terminal prompts for an agent. Use --agent (or
one of the shortcuts) to skip the selection prompt, including from automation.
EOF
}

while (($#)); do
    case "$1" in
        --agent)
            [[ $# -ge 2 ]] || { echo "--agent requires claude or codex." >&2; exit 2; }
            AGENT="$2"
            shift 2
            ;;
        --claude)
            AGENT="claude"
            shift
            ;;
        --codex)
            AGENT="codex"
            shift
            ;;
        -h | --help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

choose_agent() {
    local choice
    while true; do
        printf '\nChoose an agent:\n  1) Claude Code\n  2) Codex\n' >/dev/tty
        read -r -p "Selection [1-2]: " choice </dev/tty
        case "$choice" in
            1 | claude | Claude) AGENT="claude"; return ;;
            2 | codex | Codex) AGENT="codex"; return ;;
            *) echo "Please enter 1 or 2." >/dev/tty ;;
        esac
    done
}

case "$AGENT" in
    claude | codex) ;;
    "")
        # A herdr-spawned pane receives no launcher arguments, so reuse the
        # choice made before herdr was attached. This also sets the default
        # agent for additional panes in the same workspace.
        if [[ -n "${HERDR_ENV:-}" && -r "$AGENT_FILE" ]]; then
            read -r AGENT <"$AGENT_FILE"
        elif [[ -t 0 && -t 1 ]]; then
            choose_agent
        else
            echo "No interactive terminal. Specify --agent claude or --agent codex." >&2
            exit 2
        fi
        ;;
    *)
        echo "Invalid agent '$AGENT'; expected claude or codex." >&2
        exit 2
        ;;
esac

case "$AGENT" in
    claude | codex) ;;
    *) echo "Invalid agent saved in $AGENT_FILE; run with --agent claude or --agent codex." >&2; exit 2 ;;
esac

mkdir -p "$STATE_DIR"
printf '%s\n' "$AGENT" >"$AGENT_FILE"

if [[ -n "${HERDR_ENV:-}" ]]; then
    command -v "$AGENT" &>/dev/null || {
        echo "$AGENT not found — run bootstrap.sh first." >&2
        exit 1
    }

    if [[ "$AGENT" == "claude" ]]; then
        unset CLAUDECODE
        unset CLAUDE_CODE_CHILD_SESSION
        exec claude --dangerously-skip-permissions --model sonnet
    fi

    exec codex --dangerously-bypass-approvals-and-sandbox
fi

command -v herdr &>/dev/null || {
    echo "herdr not found — run bootstrap.sh first." >&2
    exit 1
}

# Protect the herdr server from the OOM killer: on memory exhaustion the
# kernel should kill a single agent pane, not the server.
SERVER_PID="$(pgrep -f '^herdr server$' | head -1 || true)"
if [[ -n "$SERVER_PID" ]]; then
    if sudo -n choom -n -1000 -p "$SERVER_PID" &>/dev/null; then
        echo "Protected herdr server (pid $SERVER_PID) from OOM killer."
    else
        echo "Warning: could not set OOM protection on herdr server (needs passwordless sudo + choom — see bootstrap.sh)."
    fi
fi

exec herdr
