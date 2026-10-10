# Background and decisions

This file captures the reasoning from the planning conversation that produced this repo.

## Goal
Run CloudCLI (Claude Code UI) on a Synology NAS so Claude Code and Codex sessions can be used from
a browser or phone, **without installing Claude Code or Codex on DSM itself**.

## Options considered

### 1. Upstream "Docker Sandboxes" (rejected)
Upstream offers an experimental mode, `npx @cloudcli-ai/cloudcli@latest sandbox ~/project`, that
uses Docker's `sbx` CLI with microVM (hypervisor-level) isolation. It supports Claude Code and
Codex only, and manages MCP through the UI instead of syncing `~/.claude`.
**Rejected** because it needs `npx`/Node and `sbx` on the host, plus microVM support. Synology
offers none of these.

### 2. Plain container, built on the NAS (superseded)
The first approach was a Container Manager project with a local Dockerfile, built on the NAS.
It works, but every build and update happens on the NAS.

### 3. Prebuilt image from GitHub Actions to GHCR (chosen)
CI builds the image, and the NAS only pulls. Benefits: no build load on the NAS, reproducible
tagged versions, an easy rollback by pinning a version tag, and daily rebuilds that pick up new
CLI releases.

## Design decisions
- **Base `node:22-bookworm` (full, not slim):** Upstream likely has native modules (e.g. a PTY
  library for the shell terminal). The full image includes build tools in case prebuilt binaries
  are missing for an architecture. Revisit slim or multi-stage builds once a working build is
  confirmed.
- **tini as PID 1:** Gives proper signal handling and reaps the zombie processes left behind by
  spawned CLI and shell processes.
- **ripgrep:** Claude Code uses it for search.
- **`HOME=/home/app`, mounted from the NAS:** Claude and Codex credentials, `~/.claude` sessions,
  and config all survive image updates.
- **Projects at `/home/app/projects`:** Session history stores absolute project paths, so this path
  must stay stable across rebuilds or old sessions won't line up.
- **Root by default, optional `user: "uid:gid"`:** Running as root creates root-owned files in the
  projects share, which is awkward over SMB. The compose file has a commented `user:` line for the
  DSM uid/gid (Synology users typically start at uid 1026, group `users` = 100).
  `/home/app` is chmod 777 so either option works.
- **Versions resolved in CI via `npm view`:** These are passed as build args. Unchanged versions
  hit the GHA layer cache, so the daily runs stay cheap.
- **Tags:** `latest` for normal use, the CloudCLI version tag for pinning or rollback, and
  `sha-*` for traceability.

## Operational notes
- GHCR packages are **private by default**. Either make the package public, or run
  `docker login ghcr.io` on the NAS with a PAT that has the `read:packages` scope.
- Container Manager does not auto-pull. Updates are either manual (Project → Action → Build, or
  `docker compose pull && docker compose up -d`) or automated with Watchtower.
- Remote access should go through Tailscale (a Synology package exists), never a public port
  forward.
- The NAS needs an x86_64 or ARM64 CPU. 32-bit ARM units can't run current Node.
- A useful side effect of the container setup: the agents can only touch what's mounted, not the
  rest of the NAS.
