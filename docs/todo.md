# Next steps and open questions

## Immediate
- [x] Create the GitHub repo, push, and watch the first Actions run.
      First run succeeded (multi-arch amd64+arm64 build, pushed to GHCR).
- [ ] Make the GHCR package public, or set up `docker login ghcr.io` on the NAS.
- [x] Set the real GitHub username in the `image:` line of `docker-compose.yml`.
      Set to `ghcr.io/xenov-x/ai-web-container:latest`.
- [ ] Deploy on the NAS and do the one-time `claude` and `codex login` via `docker exec`.
- [ ] Confirm the UI loads at `http://<nas-ip>:3001` from another device.

## Unverified assumptions (check these first if something breaks)
- [x] **Bind address / port env vars:** Confirmed by reading upstream `server/index.ts` and
      `.env.example`. The server reads `HOST` (default `0.0.0.0`) and `SERVER_PORT` (default
      `3001`). It does NOT read `PORT`. The Dockerfile has been fixed to set `SERVER_PORT=3001`.
- [ ] **Native modules on arm64:** The CI build succeeded for arm64, but runtime hasn't been
      tested yet (specifically the shell terminal / node-pty).
- [x] **Claude Code via npm:** The `@anthropic-ai/claude-code` npm package is actively published
      (v2.1.296 as of 2026-10-10). Still the right install path for a container.
- [ ] **Codex login flow inside a headless container:** Confirm `codex login` works over
      `docker exec` without a local browser (a device-code flow may be needed).
- [ ] **Running as a non-root `user:`:** Confirm npm-global CLIs and the UI work when the container
      runs as the DSM uid.

## NAS details still unknown
- [ ] CPU architecture. If it's x86_64, drop `linux/arm64` from `PLATFORMS` in the workflow to cut
      build time.
- [ ] DSM uid/gid for the `user:` line (run `id` over SSH).

## Possible improvements
- [ ] Skip the push when none of the resolved npm versions changed since the last build.
- [ ] Add a `HEALTHCHECK` (curl `localhost:3001`).
- [ ] Use a native arm64 runner instead of QEMU, with a matrix build plus manifest merge.
- [ ] Optimize image size (slim base or multi-stage) once a working build is confirmed.
- [ ] Add a Watchtower service to the compose file for automatic updates.
- [ ] Add Trivy or another image scan to CI.
