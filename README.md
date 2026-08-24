# agentists-quickstart

Turns a bare Debian/Ubuntu VPS into a working Claude Code/Codex + [herdr](https://herdr.dev)
coding environment. Two scripts, nothing else required.

## Quick start

On a fresh **headless server** (not your laptop/desktop — see below):

```bash
curl -fsSL https://raw.githubusercontent.com/jedarden/agentists-quickstart/main/bootstrap.sh | bash
```

The very first time, run `source ~/.profile` (or just reconnect over SSH) once — `~/.local/bin`
didn't exist yet when this shell logged in, so it isn't on `PATH` until the next login.
`bootstrap.sh` will tell you if this applies. After that, any time you want to start or
rejoin a session, from any shell:

```bash
start.sh
```

This prompts for Claude Code or Codex. To skip the selection prompt, specify the
agent explicitly:

```bash
start.sh --agent claude
start.sh --agent codex
```

`--claude` and `--codex` are equivalent shortcuts. The selected agent also becomes
the default for new Herdr panes.

## What each script does

- **`bootstrap.sh`** — one-time setup. Installs Claude Code, Codex, and herdr, wires up
  both Herdr agent integrations, and sets up `start.sh` + a passwordless-sudo rule it
  needs for OOM protection. Safe to re-run — every step is idempotent.
- **`start.sh`** — selects an agent and launches a session. Run from a plain terminal,
  it launches/attaches Herdr and the selected agent runs inside it automatically.

## Not for your personal computer

`bootstrap.sh` runs the agents with their approval and sandbox checks bypassed. That's
fine on a dedicated VPS; it's not something you want on a machine with your own files,
browser sessions, or SSH keys on it. `bootstrap.sh` checks for signs it's running on a
laptop/desktop (chassis type, battery, an active display) and asks for explicit
confirmation before proceeding if so.

## Prerequisites

- A Debian or Ubuntu VPS (apt-based — other distros aren't supported yet)
- A user with sudo access

---

Part of [jedarden.com](https://jedarden.com) · Read the write-up: [jedarden.com/guides/workflow/](https://jedarden.com/guides/workflow/)

*This GitHub repo is a read-only mirror of git.ardenone.com/jedarden/agentists-quickstart — issues and PRs are welcome here either way.*
