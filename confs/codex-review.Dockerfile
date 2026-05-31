FROM node:22

ARG CODEX_VERSION=latest

RUN apt-get update -qq && \
    apt-get install -qq -y bash ca-certificates git ripgrep && \
    rm -rf /var/lib/apt/lists/*

RUN if [ "$CODEX_VERSION" = "latest" ]; then \
        npm install -g @openai/codex; \
    else \
        npm install -g "@openai/codex@$CODEX_VERSION"; \
    fi && \
    rm -rf /root/.npm /tmp/*

RUN useradd -m -s /bin/bash codex
USER codex
WORKDIR /workspace
