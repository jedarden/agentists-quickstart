# agentists-quickstart — plan

## Architecture

Two scripts, no other moving parts:

- `bootstrap.sh` — one-time, idempotent VPS provisioning (Claude Code, Codex, herdr,
  both agent integrations, a `~/.bashrc` auto-launch hook, and an OOM-protection
  sudoers rule).
- `start.sh` — agent selector and session entry point. It records the interactive or
  flag-selected agent, then branches on `$HERDR_ENV`: set → exec that agent directly;
  unset → exec `herdr`, which re-invokes `start.sh` in the new pane via the hook.

No server component, no data model. Debian/Ubuntu (apt) only.

## Predecessor

This repo replaces `agentists-quickstart-deprecated` (renamed, not deleted — history
intact there), which was a DevPod/devcontainer template with branch-per-workspace
configs. That approach was retired in favor of matching how the reference host actually
runs: bare VPS + herdr, no containers.

## Implementation phases

- [x] Phase 1: `bootstrap.sh` — personal-machine guard, package installs, herdr +
      Claude Code/Codex, sudoers rule, `.bashrc` hook.
- [x] Phase 2: `start.sh` — agent selection, `HERDR_ENV` branch, OOM protection, herdr
      launch.
- [x] Phase 3: README + CLAUDE.md (agent-facing operating notes).
- [ ] Phase 4: Validate end-to-end on an actual fresh VPS (has only been reviewed, not
      run against a real fresh box yet).

## Open questions

- No fleet/multi-agent-naming support (such as NATO names). The launcher supports a
  single persisted Claude/Codex choice used by newly created panes.
- Other distros (non-apt) are unsupported; add if/when actually needed.
