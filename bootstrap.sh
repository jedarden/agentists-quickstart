#!/usr/bin/env bash
# bootstrap.sh — one-time setup: turns a bare Debian/Ubuntu VPS into a
# Claude Code + herdr coding environment. Safe to re-run (idempotent).
#
#   curl -fsSL https://raw.githubusercontent.com/jedarden/agentists-quickstart/main/bootstrap.sh | bash
#
set -euo pipefail

START_SH_URL="https://raw.githubusercontent.com/jedarden/agentists-quickstart/main/start.sh"
BIN_DIR="$HOME/.local/bin"
FORCE="${BOOTSTRAP_FORCE:-0}"
[[ "${1:-}" == "--force" ]] && FORCE=1

log() { echo "[bootstrap] $*"; }
err() { echo "[bootstrap] ERROR: $*" >&2; exit 1; }

# --- Refuse to run on what looks like a personal computer, without consent ---
# This installs `claude --dangerously-skip-permissions` sessions by default —
# fine on a dedicated VPS, not something you want on a machine with your own
# files, browser sessions, or SSH keys on it.
looks_personal() {
    if command -v hostnamectl &>/dev/null; then
        case "$(hostnamectl chassis 2>/dev/null)" in
            desktop | laptop | convertible | tablet) return 0 ;;
        esac
    fi
    compgen -G "/sys/class/power_supply/BAT*" &>/dev/null && return 0
    [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]] && return 0
    return 1
}

if looks_personal && [[ "$FORCE" != "1" ]]; then
    echo "This looks like a personal computer (laptop/desktop with a display), not a headless server."
    echo "Re-run with --force (or BOOTSTRAP_FORCE=1) if you're sure you want this here."
    if [[ -r /dev/tty ]]; then
        read -r -p "Type 'yes' to continue anyway: " confirm </dev/tty
        [[ "$confirm" == "yes" ]] || err "aborted."
    else
        err "no controlling terminal to confirm on — refusing to proceed non-interactively."
    fi
fi

# --- Package manager check ---
command -v apt-get &>/dev/null || err "apt-get not found — only Debian/Ubuntu are supported."

# --- Baseline packages ---
log "installing baseline packages..."
sudo apt-get update -qq
sudo apt-get install -y -qq git curl ca-certificates

# --- Claude Code CLI ---
get_installed_claude_version() {
    command -v claude &>/dev/null && claude --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}
get_latest_claude_version() {
    curl -fsSL "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/latest" 2>/dev/null \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1
}
version_lt() {
    [[ "$1" == "$2" ]] && return 1
    [[ "$(printf '%s\n%s' "$1" "$2" | sort -V | head -n1)" == "$1" ]]
}

[[ -x "$HOME/.claude/local/bin/claude" ]] && export PATH="$HOME/.claude/local/bin:$PATH"
installed="$(get_installed_claude_version || true)"
latest="$(get_latest_claude_version || true)"
if [[ -z "$installed" ]]; then
    log "installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
    [[ -x "$HOME/.claude/local/bin/claude" ]] && export PATH="$HOME/.claude/local/bin:$PATH"
    command -v claude &>/dev/null || err "Claude Code install failed."
    log "Claude Code installed: $(get_installed_claude_version)"
elif [[ -n "$latest" ]] && version_lt "$installed" "$latest"; then
    log "updating Claude Code $installed -> $latest..."
    curl -fsSL https://claude.ai/install.sh | bash
else
    log "Claude Code up to date ($installed)."
fi

# --- herdr ---
if ! command -v herdr &>/dev/null; then
    log "installing herdr..."
    curl -fsSL https://herdr.dev/install.sh | sh
    [[ -x "$BIN_DIR/herdr" ]] && export PATH="$BIN_DIR:$PATH"
    command -v herdr &>/dev/null || err "herdr install failed."
    log "herdr installed: $(herdr --version 2>&1)"
else
    log "herdr already installed ($(herdr --version 2>&1))."
fi

log "wiring herdr's Claude Code integration..."
herdr integration install claude \
    || log "warning: 'herdr integration install claude' failed — start.sh still works, session-identity persistence won't."

# --- Passwordless sudo for OOM protection (start.sh uses this to protect
#     the herdr server process — losing it takes every pane down at once) ---
SUDOERS_FILE="/etc/sudoers.d/herdr-oom-protect"
if [[ ! -f "$SUDOERS_FILE" ]]; then
    log "granting passwordless 'choom' so start.sh can protect the herdr server from the OOM killer..."
    CHOOM_PATH="$(command -v choom || echo /usr/bin/choom)"
    echo "$USER ALL=(root) NOPASSWD: ${CHOOM_PATH} -n -1000 -p *" | sudo tee "$SUDOERS_FILE" >/dev/null
    sudo chmod 440 "$SUDOERS_FILE"
fi

# --- Install start.sh to a stable, on-PATH location ---
mkdir -p "$BIN_DIR"
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/start.sh" ]]; then
    cp "$(dirname "${BASH_SOURCE[0]}")/start.sh" "$BIN_DIR/start.sh"
else
    curl -fsSL "$START_SH_URL" -o "$BIN_DIR/start.sh"
fi
chmod +x "$BIN_DIR/start.sh"

# --- Auto-launch claude in every pane herdr creates ---
# herdr sets HERDR_ENV (+ HERDR_PANE_ID/HERDR_TAB_ID/HERDR_WORKSPACE_ID) in
# every pane it spawns. This hook makes each new pane immediately hand off to
# start.sh, which sees HERDR_ENV set and execs claude directly — so running
# `start.sh` in a plain terminal (which launches herdr) results in claude
# actually running, without any separate pane-orchestration logic needed.
BASHRC_HOOK='[[ -n "$HERDR_ENV" ]] && [[ $- == *i* ]] && exec "$HOME/.local/bin/start.sh"'
if ! grep -qF "$BASHRC_HOOK" "$HOME/.bashrc" 2>/dev/null; then
    log "adding herdr auto-launch hook to ~/.bashrc..."
    {
        echo ""
        echo "# agentists-quickstart: auto-launch claude in herdr-spawned panes"
        echo "$BASHRC_HOOK"
    } >>"$HOME/.bashrc"
fi

log "done. Run 'start.sh' to launch a session."
