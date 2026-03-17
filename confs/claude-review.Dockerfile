FROM node:22

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update -qq && \
    apt-get install -qq -y gh && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code && \
    rm -rf /root/.npm /tmp/*

RUN useradd -m -s /bin/bash claude
USER claude
WORKDIR /workspace
