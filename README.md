# cloudcli-docker

Prebuilt container for [CloudCLI / Claude Code UI](https://github.com/siteboon/claudecodeui)
with Claude Code and Codex bundled inside, so nothing is installed on the host.

Built daily by GitHub Actions and published to `ghcr.io/<you>/cloudcli-docker`
for amd64 and arm64.

## NAS setup
1. Create `/volume1/docker/cloudcli/home` and `/volume1/docker/cloudcli/projects`.
2. Edit `docker-compose.yml` (set your GitHub username) and create a Container Manager project from it.
3. Log in once:
   ```
   sudo docker exec -it cloudcli claude
   sudo docker exec -it cloudcli codex login
   ```
4. Open `http://<nas-ip>:3001`.

## Updating
Pull the image and recreate the container (Container Manager: Project → Action → Build, or
`docker compose pull && docker compose up -d`). Logins and sessions persist in `home/`.
