ARG ACTIONS_RUNNER=2.325.0
# It's often better to use a base image with a specific OS tag, e.g., focal or jammy
FROM ghcr.io/actions/actions-runner:${ACTIONS_RUNNER}

# Switch to root user to perform installations
USER root

# Define versions for the tools to be installed
ARG GO_VERSION=1.24.4
ARG GH_VERSION=2.74.1
ARG KUBECTL_VERSION=v1.33.1
ARG HELM_VERSION=3.18.2

# Corrected Dockerfile RUN command
RUN apt-get update && \
    # Install dependencies
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg && \
    \
    # Install Go
    echo "Installing Go v${GO_VERSION}..." && \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    rm go.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin' > /etc/profile.d/go.sh && \
    \
    # Install GitHub CLI by downloading the specific .deb package
    echo "Installing GitHub CLI v${GH_VERSION}..." && \
    curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.deb" -o gh_cli.deb && \
    dpkg -i gh_cli.deb && \
    rm gh_cli.deb && \
    \
    # Install kubectl
    echo "Installing kubectl v${KUBECTL_VERSION}..." && \
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl && \
    \
    # Install Helm
    echo "Installing Helm v${HELM_VERSION}..." && \
    curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
    tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf helm-v${HELM_VERSION}-linux-amd64.tar.gz linux-amd64 && \
    \
    # Clean up apt caches
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# The helm plugin install must be separate since it depends on the helm binary
# The conditional check is useful here to prevent build failures if the plugin exists
RUN if ! helm plugin list | grep -q 'diff'; then \
      helm plugin install https://github.com/databus23/helm-diff; \
    fi

# Switch back to the non-privileged runner user
USER runner