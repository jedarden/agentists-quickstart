# agentists-quickstart — plan

## Architecture

Two scripts, no other moving parts:

- `bootstrap.sh` — one-time, idempotent VPS provisioning (Claude Code, herdr, herdr's
  Claude integration, a `~/.bashrc` auto-launch hook, an OOM-protection sudoers rule).
- `start.sh` — session entry point. Branches on `$HERDR_ENV`: set → exec `claude`
  directly; unset → exec `herdr`, which (via the bootstrap-installed `.bashrc` hook)
  re-invokes `start.sh` in the new pane, hitting the first branch.

No server component, no data model. Debian/Ubuntu (apt) only.

## Predecessor

This repo replaces `agentists-quickstart-deprecated` (renamed, not deleted — history
intact there), which was a DevPod/devcontainer template with branch-per-workspace
configs. That approach was retired in favor of matching how the reference host actually
runs: bare VPS + herdr, no containers.

## Implementation phases

- [x] Phase 1: `bootstrap.sh` — personal-machine guard, package installs, herdr +
      Claude Code, sudoers rule, `.bashrc` hook.
- [x] Phase 2: `start.sh` — `HERDR_ENV` branch, OOM protection, herdr launch.
- [x] Phase 3: README + CLAUDE.md (agent-facing operating notes).
- [ ] Phase 4: Validate end-to-end on an actual fresh VPS (has only been reviewed, not
      run against a real fresh box yet).

## Open questions

- No fleet/multi-agent-naming support (NATO names, per-pane agent-kind choice) — the
  predecessor repo's ADRs explored this at length; deliberately left out here unless a
  concrete need comes up.
- Other distros (non-apt) are unsupported; add if/when actually needed.
