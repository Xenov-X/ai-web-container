# CLAUDE.md

## What this repo is
A packaging repo that builds a Docker image for **CloudCLI (aka Claude Code UI)**,
https://github.com/siteboon/claudecodeui, with the **Claude Code** and **Codex** CLIs bundled inside.
GitHub Actions builds and publishes the image to GHCR. A Synology NAS pulls the prebuilt image and
runs it via Container Manager.

This repo contains no application code. It only holds the Dockerfile, the CI workflow, the NAS
compose file, and docs.

## Hard constraint
**Nothing may be installed on the Synology host OS (DSM)** other than Container Manager.
Claude Code, Codex, Node, etc. must live only inside the image. Don't propose solutions that need
host installs. That includes Docker Sandboxes / the `sbx` CLI, which needs microVM support that
Synology lacks.

## Layout
- `Dockerfile`: node:22-bookworm base, plus ripgrep and tini. Installs `@cloudcli-ai/cloudcli`,
  `@anthropic-ai/claude-code` and `@openai/codex` globally, with versions taken from build args.
  `HOME=/home/app`, workdir `/home/app/projects`, port 3001.
- `.github/workflows/build.yml`: runs on push to main, daily cron (04:00 UTC) and manual dispatch.
  Resolves the latest npm versions, then builds multi-arch (amd64 + arm64 via QEMU) and pushes
  `ghcr.io/<owner>/<repo>` with tags `latest`, `<cloudcli version>` and `sha-<short>`.
- `docker-compose.yml`: what the NAS runs. Pulls the image and mounts
  `/volume1/docker/cloudcli/home` → `/home/app` and `/volume1/docker/cloudcli/projects` →
  `/home/app/projects`.
- `docs/context.md`: background, decisions, and the reasoning behind them.
- `docs/todo.md`: open questions, unverified assumptions, next steps.

## Key facts about the upstream app
- It's a Node app that requires Node 22+ and serves its web UI on port 3001.
- It discovers sessions from `~/.claude` and reads and writes the same config Claude Code uses.
  That's why all state lives in the mounted `/home/app` volume.
- It supports Claude Code, Cursor CLI and Codex. We bundle only Claude Code and Codex.
- Claude Code tools are disabled by default in the UI and are enabled under Settings.
- The license is AGPL-3.0. We only repackage it unmodified, so no source-disclosure obligations
  apply, but keep it that way unless you're intentionally taking on AGPL obligations.

## Conventions
- Keep the image self-contained. Persistent state belongs in `/home/app` (the mounted volume) and
  never baked into the image.
- Pin versions through build args, not by editing the Dockerfile.
- Any change to paths or ports must be mirrored in `docker-compose.yml` and `README.md`.
- Security: the UI grants shell and file access. Never suggest exposing port 3001 to the internet.
  Use LAN access only, or Tailscale.

## Useful commands
```bash
# local test build
docker build -t cloudcli-local .
docker run --rm -p 3001:3001 -v "$PWD/.tmp-home:/home/app" cloudcli-local
# one-time logins on the NAS
sudo docker exec -it cloudcli claude
sudo docker exec -it cloudcli codex login
```

## Where we left off
The repo files are written but **not yet pushed or tested**. See `docs/todo.md` for the next steps
and the assumptions that still need verification.
