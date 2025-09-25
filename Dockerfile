FROM ubuntu:22.04

# Define GitHub Actions runner version
ARG RUNNER_VERSION=2.328.0
ENV RUNNER_VERSION=${RUNNER_VERSION}

# Install dependencies, including SkiaSharp / System.Drawing libraries and Docker CLI
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    unzip \
    git \
    libfontconfig1 \
    libfreetype6 \
    libx11-6 \
    libxrender1 \
    libxext6 \
    libgdiplus \
    libicu70 \
    libxml2 \
    zlib1g \
    wget \
    docker.io \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Add a non-root user for the GitHub runner
RUN useradd -m -s /bin/bash runner

# Copy entrypoint scripts
COPY entrypoint.sh /entrypoint.sh
COPY entrypoint-runner.sh /home/runner/entrypoint-runner.sh
RUN chmod +x /entrypoint.sh /home/runner/entrypoint-runner.sh

# Download GitHub Actions runner
RUN mkdir -p /home/runner/actions-runner && \
    cd /home/runner/actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar -xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    ./bin/installdependencies.sh

# Start as root (needed for dynamic docker group handling in entrypoint)
USER root
WORKDIR /home/runner

# Ensure dotnet global tools are in PATH
ENV PATH="${PATH}:/home/runner/.dotnet/tools"

ENTRYPOINT ["/entrypoint.sh"]
