FROM node:22-bookworm

# Versions are passed in by the GitHub Action; "latest" is the fallback for local builds
ARG CLOUDCLI_VERSION=latest
ARG CLAUDE_CODE_VERSION=latest
ARG CODEX_VERSION=latest

RUN apt-get update \
 && apt-get install -y --no-install-recommends ripgrep tini \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g \
      @cloudcli-ai/cloudcli@${CLOUDCLI_VERSION} \
      @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION} \
      @openai/codex@${CODEX_VERSION} \
 && npm cache clean --force

# All state (logins, sessions, config) lives under /home/app, which is mounted from the NAS
ENV HOME=/home/app \
    HOST=0.0.0.0 \
    SERVER_PORT=3001
RUN mkdir -p /home/app/projects && chmod 777 /home/app /home/app/projects
WORKDIR /home/app/projects

EXPOSE 3001
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["cloudcli"]
