ARG ACTIONS_RUNNER=2.325.0
FROM ghcr.io/actions/actions-runner:${ACTIONS_RUNNER}

USER root

ARG GO_VERSION=1.24.4
ARG GH_VERSION=2.74.0
ARG KUBECTL_VERSION=v1.33.1
ARG HELM_VERSION=3.18.2

# Install Go
RUN if [ -n "$GO_VERSION" ]; then \
      INSTALLED_GO=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//') || true; \
      if [ "$INSTALLED_GO" != "$GO_VERSION" ]; then \
        rm -rf /usr/local/go && \
        curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o go.tar.gz && \
        tar -C /usr/local -xzf go.tar.gz && rm go.tar.gz; \
      fi; \
    fi && \
    echo "export PATH=\$PATH:/usr/local/go/bin" >> /etc/profile.d/go.sh

# Install GitHub CLI
RUN if [ -n "$GH_VERSION" ]; then \
      INSTALLED_GH=$(gh --version 2>/dev/null | head -n1 | awk '{print $3}' || true); \
      if [ "$INSTALLED_GH" != "$GH_VERSION" ]; then \
        apt-get update && apt-get install -y gnupg lsb-release apt-transport-https ca-certificates && \
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
          | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" \
          > /etc/apt/sources.list.d/github-cli.list && \
        apt-get update && apt-get install -y gh && \
        apt-get clean && rm -rf /var/lib/apt/lists/*; \
      fi; \
    fi

# Install kubectl
RUN if [ -n "$KUBECTL_VERSION" ]; then \
      INSTALLED_KUBECTL=$(kubectl version --client --output=yaml 2>/dev/null \
        | grep gitVersion | awk '{print $2}' | tr -d '"' || true); \
      if [ "$INSTALLED_KUBECTL" != "$KUBECTL_VERSION" ]; then \
        curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
        install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl; \
      fi; \
    fi

# Install Helm
RUN if [ -n "$HELM_VERSION" ]; then \
      INSTALLED_HELM=$(helm version --short --client 2>/dev/null \
        | sed 's/^v//' || true); \
      if [ "$INSTALLED_HELM" != "$HELM_VERSION" ]; then \
        curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
        tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
        mv linux-amd64/helm /usr/local/bin/helm && \
        chmod +x /usr/local/bin/helm && \
        rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64; \
      fi; \
    fi

# Install helm-diff plugin if missing
RUN if ! helm plugin list | grep -q 'diff'; then \
      helm plugin install https://github.com/databus23/helm-diff; \
    fi

USER runner
