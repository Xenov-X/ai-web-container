# Next steps and open questions

## Immediate
- [ ] Create the GitHub repo, push, and watch the first Actions run.
- [ ] Make the GHCR package public, or set up `docker login ghcr.io` on the NAS.
- [ ] Set the real GitHub username in the `image:` line of `docker-compose.yml`.
- [ ] Deploy on the NAS and do the one-time `claude` and `codex login` via `docker exec`.
- [ ] Confirm the UI loads at `http://<nas-ip>:3001` from another device.

## Unverified assumptions (check these first if something breaks)
- [ ] **Bind address / port env vars:** The Dockerfile sets `HOST=0.0.0.0` and `PORT=3001`, but it
      hasn't been confirmed that cloudcli reads these variable names. Upstream says you access it
      via `[yourip]:port`, which suggests it binds to all interfaces. Check upstream `.env.example`
      and the server code.
- [ ] **Native modules on arm64:** Confirm the QEMU arm64 build succeeds and that the shell
      terminal works on arm64.
- [ ] **Claude Code via npm:** Anthropic may now recommend its native installer over the npm
      package. Check the current docs, and decide whether to switch while keeping updates
      reproducible.
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
