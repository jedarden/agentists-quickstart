# agentists-quickstart

Turns a bare Debian/Ubuntu VPS into a working Claude Code + [herdr](https://herdr.dev)
coding environment. Two scripts, nothing else required.

## Quick start

On a fresh **headless server** (not your laptop/desktop — see below):

```bash
curl -fsSL https://raw.githubusercontent.com/jedarden/agentists-quickstart/main/bootstrap.sh | bash
```

Then, any time you want to start or rejoin a session:

```bash
start.sh
```

## What each script does

- **`bootstrap.sh`** — one-time setup. Installs Claude Code, installs herdr, wires up
  herdr's Claude Code integration, and sets up `start.sh` + a passwordless-sudo rule it
  needs for OOM protection. Safe to re-run — every step is idempotent.
- **`start.sh`** — launches a session. Run from a plain terminal, it launches/attaches
  herdr and a Claude Code instance runs inside it automatically. Run from inside a
  herdr-managed pane (which is how it ends up re-invoked automatically), it just runs
  `claude` directly.

## Not for your personal computer

`bootstrap.sh` runs `claude --dangerously-skip-permissions` sessions by default. That's
fine on a dedicated VPS; it's not something you want on a machine with your own files,
browser sessions, or SSH keys on it. `bootstrap.sh` checks for signs it's running on a
laptop/desktop (chassis type, battery, an active display) and asks for explicit
confirmation before proceeding if so.

## Prerequisites

- A Debian or Ubuntu VPS (apt-based — other distros aren't supported yet)
- A user with sudo access
